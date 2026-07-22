#![allow(elided_lifetimes_in_paths)]
#![allow(clippy::wildcard_imports)]
pub use sea_orm_migration::prelude::*;

mod m20220101_000001_users;
mod m20241118_154326_tenants;
mod m20241118_155304_depts;
mod m20241118_155430_chats;
mod m20241118_155555_messages;
mod m20241118_160141_accounts;
mod m20241213_022908_feeds;
mod m20250710_190001_pipelines;
mod m20250711_110001_settings;
mod m20250722_110001_cmvs;
mod m20250806_110001_calendars;
mod m20250806_120001_schedules;
mod m20250806_130001_cycleds;
mod m20250807_100001_user2calenadrs;
mod m20250808_110001_calendars_enable;
mod m20250808_120001_cycleds_expand;
mod m20250808_130001_user2calendars_recreate;
mod m20250715_000001_office_documents;
mod m20250715_000002_files;
mod m20250808_140001_schedule_reminders;
mod m20250809_000001_meetings;
mod m20260720_100001_office_m3;
mod m20260720_100002_office_m4;
mod m20260720_100003_files_thumbnail;
mod m20260720_100004_messages_ref;
mod m20260720_100005_chats_m2;
mod m20260720_100006_group_mutes;
mod m20260720_100007_join_requests;
mod m20260720_100008_invite_links;
mod m20260721_100001_message_pins;
mod m20260722_100002_messages_thread_root;
mod m20260723_100003_chat_threads;
mod m20260724_100004_user_presence;
mod m20260725_100005_chats_allow_at_all;
mod m20260726_100001_search_indexes;
mod m20260727_100001_scheduled_messages;
pub struct Migrator;

#[async_trait::async_trait]
impl MigratorTrait for Migrator {
    fn migrations() -> Vec<Box<dyn MigrationTrait>> {
        vec![
            // inject-below
            Box::new(m20241213_022908_feeds::Migration),
            Box::new(m20241118_160141_accounts::Migration),
            Box::new(m20241118_155555_messages::Migration),
            Box::new(m20241118_155430_chats::Migration),
            Box::new(m20241118_155304_depts::Migration),
            Box::new(m20241118_154326_tenants::Migration),
            Box::new(m20220101_000001_users::Migration),
            Box::new(m20250710_190001_pipelines::Migration),
            Box::new(m20250711_110001_settings::Migration),
            Box::new(m20250722_110001_cmvs::Migration),
            Box::new(m20250806_110001_calendars::Migration),
            Box::new(m20250806_120001_schedules::Migration),
            Box::new(m20250806_130001_cycleds::Migration),
            Box::new(m20250807_100001_user2calenadrs::Migration),
            Box::new(m20250808_110001_calendars_enable::Migration),
            Box::new(m20250808_120001_cycleds_expand::Migration),
            Box::new(m20250808_130001_user2calendars_recreate::Migration),
            Box::new(m20250808_140001_schedule_reminders::Migration),
            Box::new(m20250809_000001_meetings::Migration),
            Box::new(m20250715_000001_office_documents::Migration),
            Box::new(m20250715_000002_files::Migration),
            Box::new(m20260720_100001_office_m3::Migration),
            Box::new(m20260720_100002_office_m4::Migration),
            Box::new(m20260720_100003_files_thumbnail::Migration),
            Box::new(m20260720_100004_messages_ref::Migration),
            Box::new(m20260720_100005_chats_m2::Migration),
            Box::new(m20260720_100006_group_mutes::Migration),
            Box::new(m20260720_100007_join_requests::Migration),
            Box::new(m20260720_100008_invite_links::Migration),
            Box::new(m20260721_100001_message_pins::Migration),
            Box::new(m20260722_100002_messages_thread_root::Migration),
            Box::new(m20260723_100003_chat_threads::Migration),
            Box::new(m20260724_100004_user_presence::Migration),
            Box::new(m20260725_100005_chats_allow_at_all::Migration),
            Box::new(m20260726_100001_search_indexes::Migration),
            Box::new(m20260727_100001_scheduled_messages::Migration),
        ]
    }
}

pub fn pk<T: IntoIden>(col: T) -> ColumnDef {
    ColumnDef::new(col)
        .big_integer()
        .not_null()
        .primary_key()
        .take()
}

pub fn pk_string<T: IntoIden>(col: T) -> ColumnDef {
    ColumnDef::new(col).string().not_null().primary_key().take()
}
