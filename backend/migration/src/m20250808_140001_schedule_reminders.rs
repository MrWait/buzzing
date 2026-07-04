use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(ScheduleReminders::Table)
                    .col(crate::pk(ScheduleReminders::Id))
                    .col(big_integer(ScheduleReminders::ScheduleId))
                    .col(big_integer(ScheduleReminders::UserId))
                    .col(big_integer(ScheduleReminders::RemindAt))
                    .col(integer(ScheduleReminders::NotifyMinute))
                    .col(big_integer_null(ScheduleReminders::SentAt))
                    .col(big_integer(ScheduleReminders::CreatedAt))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_remind_at_sent")
                    .table(ScheduleReminders::Table)
                    .col(ScheduleReminders::RemindAt)
                    .col(ScheduleReminders::SentAt)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_schedule_id")
                    .table(ScheduleReminders::Table)
                    .col(ScheduleReminders::ScheduleId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(ScheduleReminders::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum ScheduleReminders {
    Table,
    Id,
    ScheduleId,
    UserId,
    RemindAt,
    NotifyMinute,
    SentAt,
    CreatedAt,
}
