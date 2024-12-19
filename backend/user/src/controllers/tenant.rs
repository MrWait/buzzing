#![allow(clippy::missing_errors_doc)]
#![allow(clippy::unnecessary_struct_initialization)]
#![allow(clippy::unused_async)]
use axum::debug_handler;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};

use crate::models::{accounts, tenants, users};
use common::{extra, model::UserBrief, BizHub};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Params {}

impl Params {
    fn update(&self, _item: &mut tenants::ActiveModel) {}
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct CreateParam {
    name: String,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct JoinParam {
    id: String,
    dept_id: String,
}

async fn load_item(ctx: &AppContext, id: i64) -> Result<tenants::TenantModel> {
    let item = tenants::Entity::find_by_id(id).one(&ctx.db).await?;
    Ok(item.ok_or_else(|| Error::NotFound)?.into())
}

#[debug_handler]
pub async fn list(State(ctx): State<AppContext>) -> Result<Response> {
    format::json(tenants::Entity::find().all(&ctx.db).await?)
}

#[debug_handler]
pub async fn add(State(ctx): State<AppContext>, Json(params): Json<Params>) -> Result<Response> {
    let mut item = tenants::ActiveModel {
        ..Default::default()
    };
    params.update(&mut item);
    let item = item.insert(&ctx.db).await?;
    format::json(item)
}

#[debug_handler]
pub async fn update(
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Json(params): Json<Params>,
) -> Result<Response> {
    let item = load_item(&ctx, id).await?;
    let mut item = item.0.into_active_model();
    params.update(&mut item);
    let item = item.update(&ctx.db).await?;
    format::json(item)
}

#[debug_handler]
pub async fn remove(Path(id): Path<i64>, State(ctx): State<AppContext>) -> Result<Response> {
    load_item(&ctx, id).await?.0.delete(&ctx.db).await?;
    format::empty()
}

#[debug_handler]
pub async fn join(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Json(params): Json<JoinParam>,
) -> Result<Response> {
    let tenant_id = params
        .id
        .parse::<i64>()
        .map_err(|_| Error::BadRequest("Param Error".to_string()))?;
    let dept_id = params
        .dept_id
        .parse::<i64>()
        .map_err(|_| Error::BadRequest("Param Error".to_string()))?;
    let info = UserBrief::from_string(&auth.claims.pid)?;
    let account = accounts::Model::find_by_id(&ctx.db, info.aid).await?.0;
    tracing::info!("get account: {:?}", account);

    let tenant = tenants::TenantModel::find_by_id(&ctx.db, tenant_id)
        .await?
        .0;
    tracing::info!("get tenant: {:?}", tenant);
    let user = users::UserModel::create_with_tenant(&ctx.db, &account, &tenant, dept_id)
        .await?
        .0;
    {
        let biz = BizHub::get()?;
        let _ = biz
            .calendar
            .create_user_default(&ctx, user.id, user.tenant_id, &user.name)
            .await;
    }

    format::json(user)
}

#[debug_handler]
pub async fn create(
    auth: auth::JWT,
    State(ctx): State<AppContext>,
    Json(params): Json<CreateParam>,
) -> Result<Response> {
    let info = UserBrief::from_string(&auth.claims.pid)?;
    let account = accounts::Model::find_by_id(&ctx.db, info.aid).await?.0;
    let avatar = if let Ok(hub) = BizHub::get() {
        hub.store_impl
            .create_text_image(&ctx, &extra(&params.name, 1), "avatar")
            .await
            .unwrap_or_default()
    } else {
        "".to_string()
    };
    let tenant = tenants::TenantModel::create(&ctx.db, &params.name, &account, avatar).await;
    let (tenant, user) = match tenant {
        Ok((tenant, user)) => (tenant.0, user),
        Err(err) => {
            tracing::info!("create tenant error: {:?}", err);
            return Err(loco_rs::Error::Model(err));
        }
    };

    {
        let biz = BizHub::get()?;
        let _ = biz
            .calendar
            .create_user_default(&ctx, user.id, user.tenant_id, &user.name)
            .await;
    }

    tracing::info!("create tenant ok: {:?}", tenant);

    format::json(tenant)
}

#[debug_handler]
pub async fn get_one(Path(id): Path<i64>, State(ctx): State<AppContext>) -> Result<Response> {
    format::json(load_item(&ctx, id).await?.0)
}

pub fn routes() -> Routes {
    Routes::new()
        .prefix("api/tenants/")
        .add("/", get(list))
        .add("/", post(add))
        .add("/create", post(create))
        .add("/join", post(join))
        .add("{id}", get(get_one))
        .add("{id}", delete(remove))
        .add("{id}", put(update))
        .add("{id}", patch(update))
}
