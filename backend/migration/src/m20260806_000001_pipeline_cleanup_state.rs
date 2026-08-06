use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(CleanupState::Table)
                    .primary_key(Index::create().col(CleanupState::Id))
                    .col(small_integer(CleanupState::Id))
                    .col(big_integer(CleanupState::LastRunAtSecs))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(CleanupState::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum CleanupState {
    Table,
    Id,
    LastRunAtSecs,
}
