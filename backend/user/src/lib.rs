#![allow(dead_code)]
mod controllers;
mod dept;
mod models;
mod user;

use async_trait::async_trait;
use common::BizUser;
use loco_rs::prelude::*;
use loco_rs::{Error, Result, app::AppContext};
use tracing::instrument;

pub use base::{mailers, util, views};
use common::{ExternApp, model::UserBrief};
use proto::idl::{command::Command, entity};

#[derive(Clone)]
pub struct AppUser;
#[async_trait]
impl ExternApp for AppUser {
    fn routes(&self, _: &AppContext) -> Vec<Routes> {
        vec![
            controllers::user::routes(),
            controllers::dept::routes(),
            controllers::tenant::routes(),
            controllers::account::routes(),
        ]
    }

    fn handled_command(&self) -> Vec<i32> {
        vec![Command::DeptGetById as i32, Command::UserGetByIds as i32]
    }

    #[instrument(skip(self, ctx, brief, packet, ws))]
    async fn handle_client_packet(
        &self,
        _cmd: i32,
        ctx: &AppContext,
        brief: &UserBrief,
        packet: &entity::Packet,
        ws: bool,
    ) -> Result<(i32, Vec<u8>)> {
        let cmd: Command = packet
            .cmd
            .try_into()
            .map_err(|_| Error::string("cmd parse error"))?;
        let (code, data) = match cmd {
            // feed
            Command::DeptGetById => dept::get_dept(ctx, brief, packet, ws).await?,
            Command::UserGetByIds => user::get_by_ids(ctx, brief, packet, ws).await?,
            _ => return Err(Error::NotFound),
        };
        Ok((code, data))
    }
}

#[async_trait]
impl BizUser for AppUser {
    async fn get_user_by_id(&self, ctx: &AppContext, user_id: i64) -> Result<entity::User> {
        use models::users::UserModel;
        let user = UserModel::find_by_id(&ctx.db, user_id)
            .await?
            .ok_or(Error::NotFound)?;
        Ok(UserModel(user).into())
    }

    async fn get_user_by_ids(
        &self,
        ctx: &AppContext,
        user_ids: Vec<i64>,
    ) -> Result<Vec<entity::User>> {
        use models::users::UserModel;
        let mut users = UserModel::find_by_ids(&ctx.db, &user_ids).await?;
        Ok(users.drain(..).map(|user| UserModel(user).into()).collect())
    }

    async fn list_depts(&self, ctx: &AppContext, _brief: &UserBrief, tenant_id: i64) -> Result<Vec<entity::Department>> {
        use sea_orm::{ColumnTrait, EntityTrait, QueryFilter};
        use base::models::_entities::depts;
        let mut depts = depts::Entity::find()
            .filter(depts::Column::TenantId.eq(tenant_id))
            .all(&ctx.db)
            .await?;
        Ok(depts.drain(..).map(|d| entity::Department {
            id: d.id,
            name: d.name,
            parent_id: d.parent_id,
            tenant_id: d.tenant_id,
            ..Default::default()
        }).collect())
    }

    async fn get_dept(&self, ctx: &AppContext, _brief: &UserBrief, dept_id: i64) -> Result<entity::Department> {
        use base::models::_entities::depts;
        use sea_orm::EntityTrait;
        let dept = depts::Entity::find_by_id(dept_id)
            .one(&ctx.db)
            .await?
            .ok_or(Error::NotFound)?;
        Ok(entity::Department {
            id: dept.id,
            name: dept.name,
            parent_id: dept.parent_id,
            tenant_id: dept.tenant_id,
            ..Default::default()
        })
    }

    async fn list_dept_members(&self, ctx: &AppContext, _brief: &UserBrief, dept_id: i64, _page: i32, _page_size: i32) -> Result<Vec<entity::User>> {
        use models::users::UserModel;
        let users = UserModel::find_by_dept_id(&ctx.db, dept_id).await?;
        Ok(users.into_iter().map(|u| {
            let um: entity::User = u.into();
            um
        }).collect())
    }
}
