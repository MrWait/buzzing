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
                    .table(JoinRequests::Table)
                    .if_not_exists()
                    .col(pk(JoinRequests::Id))
                    .col(big_integer(JoinRequests::ChatId))
                    .col(big_integer(JoinRequests::UserId))
                    .col(
                        ColumnDef::new(JoinRequests::Status)
                            .small_integer()
                            .not_null()
                            .default(0),
                    )
                    .col(big_integer_null(JoinRequests::HandlerId))
                    .col(
                        ColumnDef::new(JoinRequests::HandledAt)
                            .timestamp_with_time_zone()
                            .null(),
                    )
                    .col(
                        ColumnDef::new(JoinRequests::CreatedAt)
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
                    .table(JoinRequests::Table)
                    .col(JoinRequests::ChatId)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .table(JoinRequests::Table)
                    .col(JoinRequests::Status)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .table(JoinRequests::Table)
                    .col(JoinRequests::UserId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(JoinRequests::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum JoinRequests {
    Table,
    Id,
    ChatId,
    UserId,
    Status,
    HandlerId,
    HandledAt,
    CreatedAt,
}
