use std::collections::HashMap;

use axum::debug_handler;
use loco_rs::prelude::*;
use proto::idl::entity;
use serde::{Deserialize, Serialize};
use tracing::debug;

use crate::mailers::account::AccountMailer;
// use crate::models::_entities::{accounts, tenants, users};
use crate::models::accounts::{LoginParams, RegisterParams};
use crate::models::tenants::TenantModel;
use crate::models::{accounts, tenants, users};
use common::{BizHub, current_ms, extra_name};

#[derive(Debug, Deserialize, Serialize)]
pub struct VerifyParams {
    pub token: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct ForgotParams {
    pub phone: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct ResetParams {
    pub token: String,
    pub password: String,
}

/// Register function creates a new user with the given parameters and sends a
/// welcome phone to the user
#[debug_handler]
async fn register(
    State(ctx): State<AppContext>,
    Json(params): Json<RegisterParams>,
) -> Result<Response> {
    debug!("start register account, req: {:?}", params);
    let avatar = if let Ok(hub) = BizHub::get() {
        hub.store_impl
            .create_text_image(&ctx, &extra_name(&params.name, 2), "avatar")
            .await
            .unwrap_or_default()
    } else {
        "".to_string()
    };

    let res = accounts::Model::create_with_password(&ctx.db, &params, &avatar).await;

    let account = match res {
        Ok(account) => account.0,
        Err(err) => {
            tracing::info!(
                message = err.to_string(),
                phone = &params.phone,
                "could not register user",
            );
            return format::json(());
        }
    };

    debug!("start gen avatar");

    tracing::info!(
        "create account success: {:?}, avatar: {:?}",
        account,
        avatar
    );

    let res = users::UserModel::create_default_with_account(&ctx.db, &account).await;

    let user = match res {
        Ok(user) => user.0,
        Err(err) => {
            tracing::info!(
                message = err.to_string(),
                phone = &params.phone,
                "could not create default user"
            );
            return format::json(());
        }
    };

    {
        let biz = BizHub::get()?;
        let _ = biz
            .calendar
            .create_user_default(&ctx, user.id, user.tenant_id, &user.name)
            .await;
    }

    tracing::info!("create user success: {:?}", user);
    tracing::info!("return: {}", serde_json::to_string(&user)?);
    // let account = account
    //     .into_active_model()
    //     .set_phone_verification_sent(&ctx.db)
    //     .await?;

    // AccountMailer::send_welcome(&ctx, &account).await?;

    format::json(user)
}

/// Verify register user. if the user not verified his phone, he can't login to
/// the system.
#[debug_handler]
async fn verify(
    State(ctx): State<AppContext>,
    Json(params): Json<VerifyParams>,
) -> Result<Response> {
    let user = accounts::Model::find_by_verification_token(&ctx.db, &params.token)
        .await?
        .0;

    if user.phone_verified_at.is_some() {
        tracing::info!(id = user.id.to_string(), "user already verified");
    } else {
        let active_model = user.into_active_model();
        let user = active_model.verified(&ctx.db).await?;
        tracing::info!(id = user.id.to_string(), "user verified");
    }

    format::json(())
}

/// In case the user forgot his password  this endpoints generate a forgot token
/// and send phone to the user. In case the phone not found in our DB, we are
/// returning a valid request for for security reasons (not exposing users DB
/// list).
#[debug_handler]
async fn forgot(
    State(ctx): State<AppContext>,
    Json(params): Json<ForgotParams>,
) -> Result<Response> {
    let Ok(user) = accounts::Model::find_by_phone(&ctx.db, &params.phone).await else {
        // we don't want to expose our users phone. if the phone is invalid we still
        // returning success to the caller
        return format::json(());
    };

    let user = user
        .0
        .into_active_model()
        .set_forgot_password_sent(&ctx.db)
        .await?;

    AccountMailer::forgot_password(&ctx, &user).await?;

    format::json(())
}

/// reset user password by the given parameters
#[debug_handler]
async fn reset(State(ctx): State<AppContext>, Json(params): Json<ResetParams>) -> Result<Response> {
    let Ok(user) = accounts::Model::find_by_reset_token(&ctx.db, &params.token).await else {
        // we don't want to expose our users phone. if the phone is invalid we still
        // returning success to the caller
        tracing::info!("reset token not found");

        return format::json(());
    };
    user.0
        .into_active_model()
        .reset_password(&ctx.db, &params.password)
        .await?;

    format::json(())
}

/// Creates a user login and returns a token
#[debug_handler]
async fn login(State(ctx): State<AppContext>, Json(params): Json<LoginParams>) -> Result<Response> {
    let account = accounts::Model::find_by_phone(&ctx.db, &params.phone).await?;

    let valid = account.verify_password(&params.password);
    let account = account.0;

    if !valid {
        return unauthorized("unauthorized!");
    }

    let jwt_secret = ctx.config.get_jwt_config()?;

    tracing::warn!("start login, {:?}", params);

    let mut users: Vec<users::UserModel> =
        users::UserModel::find_by_aid(&ctx.db, account.id).await?;
    let mut account = entity::Account {
        id: account.id,
        name: account.name,
        users: Vec::new(),
        version: account.version,
    };
    let mut tenant_ids = Vec::new();
    account.users = users
        .drain(..)
        .map(|user| {
            let token = user
                .generate_jwt(&jwt_secret.secret, &jwt_secret.expiration)
                .unwrap_or("unauthorized".to_string());
            let user = user.0;
            let now = current_ms() as i64 + jwt_secret.expiration as i64 * 1000;
            if user.tenant_id != 0 {
                tenant_ids.push(user.tenant_id);
            }
            entity::LoginUser {
                user: Some(entity::User {
                    id: user.id,
                    name: user.name,
                    tenant_id: user.tenant_id,
                    avatar: user.avatar.unwrap_or_default(),
                    status: user.status as i32,
                    version: user.version,
                    dept_id: user.dept_id,
                }),
                token,
                tenant: None,
                token_expire: now,
            }
        })
        .collect();
    let mut tenants = tenants::TenantModel::find_by_ids(&ctx.db, tenant_ids).await?;
    let mut tenants: HashMap<i64, _> = tenants.drain(..).map(|t| (t.id, t)).collect();
    for ref mut user in account.users.iter_mut() {
        let id = user.user.as_ref().map(|u| u.tenant_id).unwrap_or(0);
        if id == 0 {
            continue;
        }
        if let Some(tenant) = tenants.remove(&id) {
            user.tenant = Some(TenantModel(tenant).into());
        }
    }
    debug!("login account: {:?}", account);
    format::json(account)
}

pub fn routes() -> Routes {
    Routes::new()
        .prefix("/api/accounts")
        .add("/register", post(register))
        .add("/verify", post(verify))
        .add("/login", post(login))
        .add("/forgot", post(forgot))
        .add("/reset", post(reset))
}
