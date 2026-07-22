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
                    .table(MessagePins::Table)
                    .if_not_exists()
                    .col(pk(MessagePins::Id))
                    .col(big_integer(MessagePins::ChatId))
                    .col(big_integer(MessagePins::MessageId))
                    .col(big_integer(MessagePins::PinnedBy))
                    .col(
                        ColumnDef::new(MessagePins::PinnedAt)
                            .timestamp_with_time_zone()
                            .not_null()
                            .default(Expr::current_timestamp()),
                    )
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .table(MessagePins::Table)
                    .unique()
                    .col(MessagePins::ChatId)
                    .col(MessagePins::MessageId)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .table(MessagePins::Table)
                    .col(MessagePins::ChatId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(MessagePins::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum MessagePins {
    Table,
    Id,
    ChatId,
    MessageId,
    PinnedBy,
    PinnedAt,
}
