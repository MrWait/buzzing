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
mod m20250808_140001_schedule_reminders;
mod m20250809_000001_meetings;
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
