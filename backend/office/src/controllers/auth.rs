use axum::debug_handler;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};

use base::models::_entities::accounts;
use common::model::UserBrief;

#[derive(Debug, Deserialize)]
pub struct LoginParams {
    pub phone: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct LoginResponse {
    pub token: String,
    pub user: UserInfo,
}

#[derive(Debug, Serialize)]
pub struct UserInfo {
    pub id: i64,
    pub name: String,
    pub avatar: String,
}

#[debug_handler]
pub async fn login(
    State(ctx): State<AppContext>,
    Json(params): Json<LoginParams>,
) -> Result<Response> {
    let account = accounts::Entity::find()
        .filter(
            model::query::condition()
                .eq(accounts::Column::Phone, &params.phone)
                .build(),
        )
        .one(&ctx.db)
        .await?
        .ok_or_else(|| Error::Unauthorized("invalid credentials".to_string()))?;

    if !loco_rs::hash::verify_password(&params.password, &account.password) {
        return unauthorized("invalid credentials");
    }

    let users = base::models::_entities::users::Entity::find()
        .filter(
            model::query::condition()
                .eq(base::models::_entities::users::Column::AId, account.id)
                .build(),
        )
        .all(&ctx.db)
        .await?;

    let user = users.first().ok_or_else(|| Error::NotFound)?;

    let jwt_secret = ctx.config.get_jwt_config()?;
    let brief = UserBrief {
        id: user.id,
        pid: user.pid.to_string(),
        aid: user.a_id,
        tenant_id: user.tenant_id,
    };

    let token = loco_rs::auth::jwt::JWT::new(&jwt_secret.secret)
        .generate_token(
            jwt_secret.expiration,
            brief.to_string(),
            serde_json::Map::new(),
        )
        .map_err(|_| Error::Unauthorized("token generation failed".to_string()))?;

    format::json(LoginResponse {
        token,
        user: UserInfo {
            id: user.id,
            name: user.name.clone(),
            avatar: user.avatar.clone().unwrap_or_default(),
        },
    })
}
