use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Cmvs::Table)
                    .col(crate::pk(Cmvs::Id))
                    .col(big_integer(Cmvs::ChatId))
                    .col(array(Cmvs::Cmv, ColumnType::BigUnsigned))
                    .col(integer(Cmvs::Count))
                    .col(big_integer(Cmvs::CreateAtMs))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Cmvs::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Cmvs {
    Table,
    Id,
    ChatId,
    Cmv,
    Count,
    CreateAtMs,
}
