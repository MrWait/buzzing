use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Schedules::Table)
                    .col(crate::pk(Schedules::Id))
                    .col(big_integer(Schedules::CalendarId))
                    .col(integer(Schedules::Type))
                    .col(big_integer(Schedules::TenantId))
                    .col(big_integer(Schedules::Owner))
                    .col(big_integer(Schedules::CycleRuleId))
                    .col(big_integer(Schedules::CycleEndTime))
                    .col(binary(Schedules::Extra))
                    .col(string(Schedules::Title))
                    .col(boolean(Schedules::Exception))
                    .col(boolean(Schedules::FullDay))
                    .col(boolean(Schedules::ShowAsIdle))
                    .col(integer(Schedules::PublicPermission))
                    .col(big_integer(Schedules::StartTime))
                    .col(big_integer(Schedules::EndTime))
                    .col(integer(Schedules::MemberCount))
                    .col(array(Schedules::MemberIds, ColumnType::BigInteger))
                    .col(big_integer(Schedules::Version))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-schedule-calendar-cycle")
                    .table(Schedules::Table)
                    .col(Schedules::CalendarId)
                    .col(Schedules::CycleRuleId)
                    .col(Schedules::CycleEndTime)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-schedule-memberids")
                    .table(Schedules::Table)
                    .full_text()
                    .col(Schedules::MemberIds)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-schedule-start-end-time")
                    .table(Schedules::Table)
                    .col(Schedules::StartTime)
                    .col(Schedules::EndTime)
                    .to_owned(),
            )
            .await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Schedules::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Schedules {
    Table,
    Id,
    CalendarId,
    Title,
    Type,
    TenantId,
    Owner,
    CycleRuleId,
    CycleEndTime,
    // room id, summary doc id, chat id, member view list,
    // member invite other, member alter schedule, member create summary
    // member create meeting, need checkin, color, archive
    // location, notify time, desc, cycle rule
    Extra,
    Exception,
    FullDay,
    ShowAsIdle,
    PublicPermission,
    StartTime,
    EndTime,
    MemberCount,
    MemberIds,
    Version,
}
