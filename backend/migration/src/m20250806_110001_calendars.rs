use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Calendars::Table)
                    .col(crate::pk(Calendars::Id))
                    .col(big_integer(Calendars::Creator))
                    .col(big_integer(Calendars::TenantId))
                    .col(boolean(Calendars::Public))
                    .col(boolean(Calendars::IsDefalut))
                    .col(integer(Calendars::Color))
                    .col(string_null(Calendars::Name))
                    .col(string_null(Calendars::Desc))
                    .col(big_integer(Calendars::Version))
                    .col(json_binary(Calendars::Subscriber))
                    .col(blob(Calendars::Extra))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-calendar-subscriber")
                    .table(Calendars::Table)
                    .col(Calendars::Subscriber)
                    .full_text()
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Calendars::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Calendars {
    Table,
    Id,
    Creator,
    TenantId,
    Public,
    IsDefalut,
    Color,
    Name,
    Desc,
    Version,
    Subscriber,
    Extra,
}
