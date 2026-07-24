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
                    .table(Versions::Table)
                    .col(crate::pk(Versions::Id))
                    .col(big_integer(Versions::AppId).not_null())
                    .col(string(Versions::Version).not_null())
                    .col(text_null(Versions::ReleaseNotes))
                    .col(small_integer(Versions::Status).not_null().default(0))
                    .col(text_null(Versions::ReviewComment))
                    .col(big_integer_null(Versions::ReviewedBy))
                    .col(timestamp_with_time_zone_null(Versions::ReviewedAt))
                    .col(timestamp_with_time_zone(Versions::CreatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx-versions_app")
                    .table(Versions::Table)
                    .col(Versions::AppId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Versions::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Versions {
    Table,
    Id,
    AppId,
    Version,
    ReleaseNotes,
    Status,
    ReviewComment,
    ReviewedBy,
    ReviewedAt,
    CreatedAt,
}
