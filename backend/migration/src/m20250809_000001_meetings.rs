use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(Meetings::Table)
                    .col(crate::pk(Meetings::Id))
                    .col(string(Meetings::RoomId).unique_key().string_len(64))
                    .col(string_len(Meetings::Title, 256).default(""))
                    .col(big_integer(Meetings::HostId))
                    .col(string_len_null(Meetings::Password, 128))
                    .col(small_integer(Meetings::Status).default(0))
                    .col(big_integer_null(Meetings::ScheduledAt))
                    .col(big_integer(Meetings::StartedAt))
                    .col(big_integer_null(Meetings::EndedAt))
                    .col(big_integer(Meetings::TenantId))
                    .col(integer(Meetings::MaxParticipants).default(4))
                    .col(json_binary(Meetings::Settings).default("{}"))
                    .col(big_integer(Meetings::CreatedAt))
                    .col(big_integer(Meetings::UpdatedAt))
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx_meetings_tenant_id")
                    .table(Meetings::Table)
                    .col(Meetings::TenantId)
                    .to_owned(),
            )
            .await?;

        manager
            .create_table(
                Table::create()
                    .table(MeetingMembers::Table)
                    .col(crate::pk(MeetingMembers::Id))
                    .col(big_integer(MeetingMembers::MeetingId))
                    .col(big_integer(MeetingMembers::UserId))
                    .col(small_integer(MeetingMembers::Role).default(0))
                    .col(small_integer(MeetingMembers::Status).default(0))
                    .col(big_integer_null(MeetingMembers::JoinedAt))
                    .col(big_integer_null(MeetingMembers::LeftAt))
                    .col(big_integer(MeetingMembers::CreatedAt))
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx_members_meeting_id")
                    .table(MeetingMembers::Table)
                    .col(MeetingMembers::MeetingId)
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx_members_user_id")
                    .table(MeetingMembers::Table)
                    .col(MeetingMembers::UserId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(MeetingMembers::Table).to_owned())
            .await?;
        manager
            .drop_table(Table::drop().table(Meetings::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Meetings {
    Table,
    Id,
    RoomId,
    Title,
    HostId,
    Password,
    Status,
    ScheduledAt,
    StartedAt,
    EndedAt,
    TenantId,
    MaxParticipants,
    Settings,
    CreatedAt,
    UpdatedAt,
}

#[derive(DeriveIden)]
enum MeetingMembers {
    Table,
    Id,
    MeetingId,
    UserId,
    Role,
    Status,
    JoinedAt,
    LeftAt,
    CreatedAt,
}
