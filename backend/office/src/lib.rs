use loco_rs::app::AppContext;
use loco_rs::prelude::*;
use std::sync::Arc;

use async_trait::async_trait;
use common::{ExternApp, BizOffice, model::UserBrief};
use proto::idl::{command::Command, entity};

pub mod controllers;
pub mod models;
pub mod pb;
pub mod permission;
pub mod ws;
pub mod yjs_store;

#[derive(Clone)]
pub struct AppOffice;
#[async_trait]
impl ExternApp for AppOffice {
    fn routes(&self, _ctx: &AppContext) -> Vec<Routes> {
        controllers::routes()
    }

    fn handled_command(&self) -> Vec<i32> {
        vec![
            Command::OfficeDocCreate as i32,
            Command::OfficeDocGet as i32,
            Command::OfficeDocUpdate as i32,
            Command::OfficeDocDelete as i32,
            Command::OfficePersonalTree as i32,
            Command::OfficeDocList as i32,
            Command::OfficeDocListTree as i32,
            Command::OfficeDocRecent as i32,
            Command::OfficeDocTrashList as i32,
            Command::OfficeDocStarred as i32,
            Command::OfficeDocStar as i32,
            Command::OfficeDocUnstar as i32,
            Command::OfficeDocRestore as i32,
            Command::OfficeDocPurge as i32,
            Command::OfficeDocMove as i32,
            Command::OfficeDocDuplicate as i32,
            Command::OfficeDocVisit as i32,
            Command::OfficeDocMy as i32,
            Command::OfficeDocShared as i32,
            Command::OfficeDocSearch as i32,
            Command::OfficeDocPermission as i32,
            Command::OfficeDocEditUrl as i32,
            Command::OfficeMemberList as i32,
            Command::OfficeMemberAdd as i32,
            Command::OfficeMemberUpdate as i32,
            Command::OfficeMemberRemove as i32,
            Command::OfficeVersionList as i32,
            Command::OfficeVersionCreate as i32,
            Command::OfficeVersionGet as i32,
            Command::OfficeVersionDiff as i32,
            Command::OfficeVersionRestore as i32,
            Command::OfficeShareCreate as i32,
            Command::OfficeShareList as i32,
            Command::OfficeShareRevoke as i32,
            Command::OfficeShareResolve as i32,
            Command::OfficeShareVerify as i32,
            Command::OfficeWikiList as i32,
            Command::OfficeWikiCreate as i32,
            Command::OfficeWikiGet as i32,
            Command::OfficeWikiUpdate as i32,
            Command::OfficeWikiDelete as i32,
            Command::OfficeWikiMemberList as i32,
            Command::OfficeWikiMemberAdd as i32,
            Command::OfficeWikiMemberRemove as i32,
            Command::OfficeWikiPinList as i32,
            Command::OfficeWikiPinAdd as i32,
            Command::OfficeWikiPinRemove as i32,
            Command::OfficeWikiRecent as i32,
            Command::OfficeMentionUsers as i32,
            Command::OfficeMentionDocs as i32,
        ]
    }

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
        pb::dispatch(cmd, ctx, brief, packet, ws).await
    }

    fn serve(&self, ctx: &AppContext) {
        let manager = Arc::new(ws::YjsManager::new(ctx.clone()));
        ws::YJS_MANAGER.set(manager).ok();

        let ctx_clone = ctx.clone();
        tokio::spawn(async move {
            ws::periodic_save_loop(ctx_clone).await;
        });

        // M3: 定时清理回收站到期文档 (每天 03:00 检查一次，粒度到小时即可)
        let ctx_clone = ctx.clone();
        tokio::spawn(async move {
            let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(3600));
            loop {
                interval.tick().await;
                match controllers::trash::cleanup_expired(&ctx_clone).await {
                    Ok(n) if n > 0 => {
                        tracing::info!(count = n, "office: cleaned expired trashed docs");
                    }
                    Ok(_) => {}
                    Err(e) => tracing::warn!(err = %e, "office: trash cleanup failed"),
                }
            }
        });
    }
}

#[async_trait::async_trait]
impl BizOffice for AppOffice {
    async fn create_user_default(
        &self,
        _ctx: &AppContext,
        _user_id: i64,
        _tenant_id: i64,
        _user_name: &str,
    ) -> Result<()> {
        // 个人空间是虚拟的，不需要创建根文档。顶层文档的 parent_id = user_id。
        Ok(())
    }
}


