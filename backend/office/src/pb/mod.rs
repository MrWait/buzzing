pub mod docs;
pub mod members;
pub mod mentions;
pub mod shares;
pub mod versions;
pub mod wikis;

use loco_rs::Result;
use proto::idl::{command::Command, entity};
use common::model::UserBrief;
use loco_rs::app::AppContext;

pub async fn dispatch(
    cmd: Command,
    ctx: &AppContext,
    brief: &UserBrief,
    packet: &entity::Packet,
    ws: bool,
) -> Result<(i32, Vec<u8>)> {
    match cmd {
        Command::OfficeDocCreate => docs::create(ctx, brief, packet, ws).await,
        Command::OfficeDocGet => docs::get(ctx, brief, packet, ws).await,
        Command::OfficeDocUpdate => docs::update(ctx, brief, packet, ws).await,
        Command::OfficeDocDelete => docs::delete(ctx, brief, packet, ws).await,
        Command::OfficePersonalTree => docs::personal_tree(ctx, brief, packet, ws).await,
        Command::OfficeDocList => docs::list(ctx, brief, packet, ws).await,
        Command::OfficeDocListTree => docs::tree(ctx, brief, packet, ws).await,
        Command::OfficeDocRecent => docs::recent(ctx, brief, packet, ws).await,
        Command::OfficeDocTrashList => docs::trash_list(ctx, brief, packet, ws).await,
        Command::OfficeDocStarred => docs::starred(ctx, brief, packet, ws).await,
        Command::OfficeDocStar => docs::star(ctx, brief, packet, ws).await,
        Command::OfficeDocUnstar => docs::unstar(ctx, brief, packet, ws).await,
        Command::OfficeDocRestore => docs::restore(ctx, brief, packet, ws).await,
        Command::OfficeDocPurge => docs::purge(ctx, brief, packet, ws).await,
        Command::OfficeDocMove => docs::r#move(ctx, brief, packet, ws).await,
        Command::OfficeDocDuplicate => docs::duplicate(ctx, brief, packet, ws).await,
        Command::OfficeDocVisit => docs::visit(ctx, brief, packet, ws).await,
        Command::OfficeDocMy => docs::my_docs(ctx, brief, packet, ws).await,
        Command::OfficeDocShared => docs::shared_docs(ctx, brief, packet, ws).await,
        Command::OfficeDocSearch => docs::search(ctx, brief, packet, ws).await,
        Command::OfficeDocPermission => docs::permission(ctx, brief, packet, ws).await,
        Command::OfficeDocEditUrl => docs::edit_url(ctx, brief, packet, ws).await,
        // Members
        Command::OfficeMemberList => members::list(ctx, brief, packet, ws).await,
        Command::OfficeMemberAdd => members::add(ctx, brief, packet, ws).await,
        Command::OfficeMemberUpdate => members::update(ctx, brief, packet, ws).await,
        Command::OfficeMemberRemove => members::remove(ctx, brief, packet, ws).await,
        // Versions
        Command::OfficeVersionList => versions::list(ctx, brief, packet, ws).await,
        Command::OfficeVersionCreate => versions::create(ctx, brief, packet, ws).await,
        Command::OfficeVersionGet => versions::get(ctx, brief, packet, ws).await,
        Command::OfficeVersionDiff => versions::diff(ctx, brief, packet, ws).await,
        Command::OfficeVersionRestore => versions::restore(ctx, brief, packet, ws).await,
        // Shares
        Command::OfficeShareCreate => shares::create(ctx, brief, packet, ws).await,
        Command::OfficeShareList => shares::list(ctx, brief, packet, ws).await,
        Command::OfficeShareRevoke => shares::revoke(ctx, brief, packet, ws).await,
        Command::OfficeShareResolve => shares::resolve(ctx, brief, packet, ws).await,
        Command::OfficeShareVerify => shares::verify(ctx, brief, packet, ws).await,
        // Wikis
        Command::OfficeWikiList => wikis::list(ctx, brief, packet, ws).await,
        Command::OfficeWikiCreate => wikis::create(ctx, brief, packet, ws).await,
        Command::OfficeWikiGet => wikis::get(ctx, brief, packet, ws).await,
        Command::OfficeWikiUpdate => wikis::update(ctx, brief, packet, ws).await,
        Command::OfficeWikiDelete => wikis::delete(ctx, brief, packet, ws).await,
        Command::OfficeWikiMemberList => wikis::member_list(ctx, brief, packet, ws).await,
        Command::OfficeWikiMemberAdd => wikis::member_add(ctx, brief, packet, ws).await,
        Command::OfficeWikiMemberRemove => wikis::member_remove(ctx, brief, packet, ws).await,
        Command::OfficeWikiPinList => wikis::pin_list(ctx, brief, packet, ws).await,
        Command::OfficeWikiPinAdd => wikis::pin_add(ctx, brief, packet, ws).await,
        Command::OfficeWikiPinRemove => wikis::pin_remove(ctx, brief, packet, ws).await,
        Command::OfficeWikiRecent => wikis::recent(ctx, brief, packet, ws).await,
        Command::OfficeWikiUpdateSecurity => wikis::update_security(ctx, brief, packet, ws).await,
        // Mentions
        Command::OfficeMentionUsers => mentions::search_users(ctx, brief, packet, ws).await,
        Command::OfficeMentionDocs => mentions::search_docs(ctx, brief, packet, ws).await,
        _ => Err(loco_rs::Error::NotFound),
    }
}
