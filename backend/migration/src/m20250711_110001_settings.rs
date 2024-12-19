use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Settings::Table)
                    .primary_key(Index::create().col(Settings::UserId).col(Settings::Type))
                    .col(big_integer(Settings::UserId))
                    .col(integer(Settings::Type))
                    .col(blob(Settings::Data))
                    .col(big_integer(Settings::Version))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Settings::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Settings {
    Table,
    UserId,
    Type,
    Data,
    Version,
}
