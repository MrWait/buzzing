use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(User2Calendars::Table)
                    .col(crate::pk(User2Calendars::UserId))
                    .col(json_binary(User2Calendars::Calendars))
                    .col(json_binary(User2Calendars::Schedules))
                    .col(big_integer(User2Calendars::Version))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-user2calendar-calendar")
                    .table(User2Calendars::Table)
                    .col(User2Calendars::Calendars)
                    .full_text()
                    .to_owned(),
            )
            .await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(User2Calendars::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum User2Calendars {
    Table,
    UserId,
    Calendars,
    Schedules,
    Version,
}
