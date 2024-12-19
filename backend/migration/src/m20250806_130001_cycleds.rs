use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Cycleds::Table)
                    .col(crate::pk(Cycleds::Id))
                    .col(big_integer(Cycleds::CalendarId))
                    .col(big_integer(Cycleds::StartAt))
                    .col(big_integer(Cycleds::StopAt))
                    .col(binary(Cycleds::Rule))
                    .col(array(Cycleds::Exceptions, ColumnType::BigInteger))
                    .col(binary(Cycleds::Template))
                    .col(big_integer(Cycleds::Version))
                    .col(blob(Cycleds::Extra))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Cycleds::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Cycleds {
    Table,
    Id,
    CalendarId,
    StartAt,
    StopAt,
    Rule,
    Exceptions,
    Template,
    Version,
    Extra,
}
