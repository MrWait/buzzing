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
                    .table(OpenAppStats::Table)
                    .col(crate::pk(OpenAppStats::Id))
                    .col(big_integer(OpenAppStats::AppId).not_null())
                    .col(date(OpenAppStats::Date).not_null())
                    .col(string(OpenAppStats::Endpoint).not_null())
                    .col(integer(OpenAppStats::CallCount).not_null().default(0))
                    .col(integer(OpenAppStats::ErrorCount).not_null().default(0))
                    .col(big_integer(OpenAppStats::TotalLatencyMs).not_null().default(0))
                    .col(integer(OpenAppStats::EventPushCount).not_null().default(0))
                    .col(integer(OpenAppStats::EventPushFailed).not_null().default(0))
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx-open_app_stats-app_date")
                    .table(OpenAppStats::Table)
                    .col(OpenAppStats::AppId)
                    .col(OpenAppStats::Date)
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx-open_app_stats_endpoint")
                    .table(OpenAppStats::Table)
                    .col(OpenAppStats::Endpoint)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(OpenAppStats::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum OpenAppStats {
    Table,
    Id,
    AppId,
    Date,
    Endpoint,
    CallCount,
    ErrorCount,
    TotalLatencyMs,
    EventPushCount,
    EventPushFailed,
}
