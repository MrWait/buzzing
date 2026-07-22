use sea_orm_migration::{prelude::*, schema::*};

fn pk<I: IntoIden>(col: I) -> ColumnDef {
    ColumnDef::new(col).big_integer().not_null().primary_key().take()
}

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(ChatThreads::Table)
                    .if_not_exists()
                    .col(pk(ChatThreads::Id))
                    .col(big_integer(ChatThreads::ChatId))
                    .col(big_integer(ChatThreads::RootMessageId))
                    .col(
                        ColumnDef::new(ChatThreads::MessageCount)
                            .integer()
                            .not_null()
                            .default(0),
                    )
                    .col(
                        ColumnDef::new(ChatThreads::LastMessageAt)
                            .timestamp_with_time_zone()
                            .null(),
                    )
                    .col(
                        ColumnDef::new(ChatThreads::LastMessageId)
                            .big_integer()
                            .null(),
                    )
                    .col(
                        ColumnDef::new(ChatThreads::LastMessageSummary)
                            .string()
                            .not_null()
                            .default(""),
                    )
                    .col(
                        ColumnDef::new(ChatThreads::LastMessageFromId)
                            .big_integer()
                            .null(),
                    )
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .table(ChatThreads::Table)
                    .unique()
                    .col(ChatThreads::ChatId)
                    .col(ChatThreads::RootMessageId)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .table(ChatThreads::Table)
                    .col(ChatThreads::ChatId)
                    .col(ChatThreads::RootMessageId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(ChatThreads::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum ChatThreads {
    Table,
    Id,
    ChatId,
    RootMessageId,
    MessageCount,
    LastMessageAt,
    LastMessageId,
    LastMessageSummary,
    LastMessageFromId,
}
