use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Feeds::Table)
                    .primary_key(
                        Index::create()
                            .col(Feeds::EntityId)
                            .col(Feeds::UserId)
                    )
                    .col(big_integer(Feeds::EntityId))
                    .col(integer(Feeds::EntityType))
                    .col(big_integer(Feeds::UserId))
                    .col(big_integer(Feeds::ReferId))
                    .col(integer(Feeds::ReferPos))
                    .col(integer(Feeds::ReferBadge))
                    .col(integer(Feeds::ReadPos))
                    .col(integer(Feeds::ReadBadge))
                    .col(big_integer(Feeds::UpdateMs))
                    .col(big_integer(Feeds::RankTimeMs))
                    .col(integer(Feeds::Status))
                    .col(integer(Feeds::IsMute))
                    .col(integer(Feeds::IsTop))
                    .col(big_integer(Feeds::Version))
                    .col(blob(Feeds::Extra))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Feeds::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Feeds {
    Table,
    EntityId,
    EntityType,
    UserId,
    ReferId,
    ReferPos,
    ReferBadge,
    ReadPos,
    ReadBadge,
    UpdateMs,
    RankTimeMs,
    Status,
    IsMute,
    IsTop,
    Version,
    Extra,
}
