use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Chats::Table)
                    .col(crate::pk(Chats::Id))
                    .col(tiny_integer(Chats::Type))
                    .col(tiny_integer(Chats::Status))
                    .col(string(Chats::Name))
                    .col(big_integer(Chats::OwnerId))
                    .col(big_integer(Chats::PeerAId))
                    .col(big_integer(Chats::PeerBId))
                    .col(blob(Chats::Cmv))
                    .col(big_integer(Chats::LastMessageId))
                    .col(integer(Chats::LastMessagePos))
                    .col(integer(Chats::LastMessageBadge))
                    .col(array(Chats::AdminIds, ColumnType::BigInteger))
                    .col(big_integer(Chats::Version))
                    .col(blob(Chats::Extra))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Chats::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Chats {
    Table,
    Id,
    Type,
    Status,
    Name,
    OwnerId,
    PeerAId,
    PeerBId,
    Cmv,
    LastMessageId,
    LastMessagePos,
    LastMessageBadge,
    AdminIds,
    Version,
    Extra,
}
