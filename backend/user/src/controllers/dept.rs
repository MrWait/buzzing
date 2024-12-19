#![allow(clippy::missing_errors_doc)]
#![allow(clippy::unnecessary_struct_initialization)]
#![allow(clippy::unused_async)]
use axum::debug_handler;
use loco_rs::controller::bad_request;
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};

use crate::models::{depts, users};
use crate::views;
use common::model::UserBrief;
use proto::idl::entity::Department;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct CreateParams {
    name: String,
    parent: i64,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct JoinParams {
    dept_id: i64,
    user_ids: Vec<i64>,
    dept_ids: Vec<i64>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Params {}

impl Params {
    fn update(&self, _item: &mut depts::ActiveModel) {}
}

async fn load_item(ctx: &AppContext, id: i64) -> Result<depts::Model> {
    let item = depts::Entity::find_by_id(id).one(&ctx.db).await?;
    Ok(item.ok_or_else(|| Error::NotFound)?.into())
}

#[debug_handler]
pub async fn list(State(ctx): State<AppContext>) -> Result<Response> {
    format::json(depts::Entity::find().all(&ctx.db).await?)
}

#[debug_handler]
pub async fn add(State(ctx): State<AppContext>, Json(params): Json<Params>) -> Result<Response> {
    let mut item = depts::ActiveModel {
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
    let item = load_item(&ctx, id).await?.0;
    let mut item = item.into_active_model();
    params.update(&mut item);
    let item = item.update(&ctx.db).await?;
    format::json(item)
}

#[debug_handler]
pub async fn join(State(_ctx): State<AppContext>) -> Result<Response> {
    format::empty()
}

#[debug_handler]
pub async fn remove(Path(id): Path<i64>, State(ctx): State<AppContext>) -> Result<Response> {
    load_item(&ctx, id).await?.0.delete(&ctx.db).await?;
    format::empty()
}

#[debug_handler]
pub async fn get_one(Path(id): Path<i64>, State(ctx): State<AppContext>) -> Result<Response> {
    format::json(load_item(&ctx, id).await?.0)
}

#[debug_handler]
pub async fn get_dept(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    let dept = depts::Model::find_by_id(&ctx.db, id).await?.0;
    if dept.tenant_id != claim.tenant_id {
        return bad_request("no permision to get");
    }

    let _depts = depts::Model::find_by_parent_id(&ctx.db, id).await?;
    let _users = users::UserModel::find_by_dept_id(&ctx.db, id).await?;

    format::json(views::dept::ListDeptResponse::new(
        id,
        Department {
            id: dept.id,
            parent_id: dept.parent_id,
            tenant_id: dept.tenant_id,
            name: dept.name,
            sub_department_ids: Vec::new(),
            member_ids: Vec::new(),
            version: dept.version,
        },
        Vec::new(),
        Vec::new(),
    ))
}

pub fn routes() -> Routes {
    Routes::new()
        .prefix("api/depts/")
        .add("/", get(list))
        .add("/add", post(add))
        .add("/join", post(join))
        .add("/detail/{id}", get(get_one))
        .add("{id}", get(get_dept))
        .add("{id}", delete(remove))
        .add("{id}", put(update))
        .add("{id}", patch(update))
}
