use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Pipelines::Table)
                    .primary_key(Index::create().col(Pipelines::Sid).col(Pipelines::UserId))
                    .col(big_integer(Pipelines::Sid))
                    .col(big_integer(Pipelines::UserId))
                    .col(integer(Pipelines::Command))
                    .col(blob(Pipelines::Data))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Pipelines::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Pipelines {
    Table,
    Sid,
    UserId,
    Command,
    Data,
}
