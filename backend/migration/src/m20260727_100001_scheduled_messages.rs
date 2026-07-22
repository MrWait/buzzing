use sea_orm_migration::{prelude::*, schema::*};

use crate::pk;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(ScheduledMessages::Table)
                    .if_not_exists()
                    .col(pk(ScheduledMessages::Id))
                    .col(big_integer(ScheduledMessages::UserId))
                    .col(big_integer(ScheduledMessages::ChatId))
                    .col(big_integer(ScheduledMessages::ClientId).default(0))
                    .col(small_integer(ScheduledMessages::Tpy))
                    .col(ColumnDef::new(ScheduledMessages::Content).binary().not_null())
                    .col(big_integer(ScheduledMessages::SendAtMs))
                    .col(small_integer(ScheduledMessages::Status).default(0))
                    .col(
                        ColumnDef::new(ScheduledMessages::CreatedAt)
                            .timestamp_with_time_zone()
                            .not_null()
                            .default(Expr::current_timestamp()),
                    )
                    .col(
                        ColumnDef::new(ScheduledMessages::UpdatedAt)
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
                    .table(ScheduledMessages::Table)
                    .name("idx_scheduled_user_status")
                    .col(ScheduledMessages::UserId)
                    .col(ScheduledMessages::Status)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .table(ScheduledMessages::Table)
                    .name("idx_scheduled_send_at")
                    .col(ScheduledMessages::SendAtMs)
                    .col(ScheduledMessages::Status)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(ScheduledMessages::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum ScheduledMessages {
    Table,
    Id,
    UserId,
    ChatId,
    ClientId,
    Tpy,
    Content,
    SendAtMs,
    Status,
    CreatedAt,
    UpdatedAt,
}
