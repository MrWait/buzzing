use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(User2Calendars::Table).to_owned())
            .await?;
        manager
            .create_table(
                Table::create()
                    .table(User2Calendars::Table)
                    .col(big_integer(User2Calendars::UserId))
                    .col(big_integer(User2Calendars::CalendarId))
                    .col(integer(User2Calendars::Color).default(0))
                    .col(integer(User2Calendars::Role).default(0))
                    .col(big_integer(User2Calendars::SubscribeTime))
                    .primary_key(
                        Index::create()
                            .col(User2Calendars::UserId)
                            .col(User2Calendars::CalendarId),
                    )
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_u2c_calendar")
                    .table(User2Calendars::Table)
                    .col(User2Calendars::CalendarId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(User2Calendars::Table).to_owned())
            .await?;
        manager
            .create_table(
                Table::create()
                    .table(User2Calendars::Table)
                    .col(crate::pk(User2Calendars::UserId))
                    .col(json_binary(User2Calendars::Calendars))
                    .col(json_binary(User2Calendars::Schedules))
                    .col(big_integer(User2Calendars::Version))
                    .to_owned(),
            )
            .await
    }
}

#[derive(DeriveIden)]
enum User2Calendars {
    Table,
    UserId,
    CalendarId,
    Color,
    Role,
    SubscribeTime,
    Calendars,
    Schedules,
    Version,
}
