use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Messages::Table)
                    .col(crate::pk(Messages::Id))
                    .col(tiny_integer(Messages::Type))
                    .col(big_integer(Messages::ChatId))
                    .col(big_integer(Messages::FromId))
                    .col(integer(Messages::Pos))
                    .col(integer(Messages::Badge))
                    .col(tiny_integer(Messages::Status))
                    .col(big_integer(Messages::ClientId))
                    .col(array(Messages::AtUserIds, ColumnType::BigInteger))
                    .col(binary(Messages::Content))
                    .col(string(Messages::Summary))
                    .col(big_integer(Messages::Version))
                    .col(big_integer(Messages::CmvId))
                    .col(integer(Messages::CmvCount))
                    .col(integer(Messages::ReadCount))
                    .col(blob(Messages::ReadStates))
                    .col(blob(Messages::Reactions))
                    .col(blob(Messages::Extra))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Messages::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Messages {
    Table,
    Id,
    Type,
    ChatId,
    FromId,
    Pos,
    Badge,
    Status,
    ClientId,
    AtUserIds,
    Content,
    Summary,
    Version,
    CmvId,
    CmvCount,
    ReadCount,
    ReadStates,
    Reactions,
    Extra,
}
