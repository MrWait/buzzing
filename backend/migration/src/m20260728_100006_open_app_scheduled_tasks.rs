use sea_orm_migration::prelude::*;
use sea_orm_migration::schema::*;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(ScheduledTasks::Table)
                    .col(crate::pk(ScheduledTasks::Id))
                    .col(big_integer(ScheduledTasks::AppId).not_null())
                    .col(string(ScheduledTasks::Name).not_null())
                    .col(string(ScheduledTasks::CronExpr).not_null())
                    .col(string(ScheduledTasks::ActionType).not_null())
                    .col(json_binary(ScheduledTasks::ActionConfig).not_null())
                    .col(big_integer_null(ScheduledTasks::ChatId))
                    .col(small_integer(ScheduledTasks::Status).not_null().default(1))
                    .col(timestamp_with_time_zone_null(ScheduledTasks::LastRunAt))
                    .col(timestamp_with_time_zone_null(ScheduledTasks::NextRunAt))
                    .col(timestamp_with_time_zone(ScheduledTasks::CreatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .col(timestamp_with_time_zone(ScheduledTasks::UpdatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx-scheduled_app")
                    .table(ScheduledTasks::Table)
                    .col(ScheduledTasks::AppId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(ScheduledTasks::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum ScheduledTasks {
    Table,
    Id,
    AppId,
    Name,
    CronExpr,
    ActionType,
    ActionConfig,
    ChatId,
    Status,
    LastRunAt,
    NextRunAt,
    CreatedAt,
    UpdatedAt,
}
