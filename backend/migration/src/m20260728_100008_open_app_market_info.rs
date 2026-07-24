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
                    .table(MarketInfo::Table)
                    .col(big_integer(MarketInfo::AppId).not_null().primary_key())
                    .col(string(MarketInfo::AppCategory).not_null().default("bot"))
                    .col(big_integer_null(MarketInfo::IconFileId))
                    .col(array(MarketInfo::Screenshots, ColumnType::BigInteger).not_null().default(Expr::cust("ARRAY[]::bigint[]")))
                    .col(string(MarketInfo::ShortDescription).not_null().default(""))
                    .col(text_null(MarketInfo::DetailedDescription))
                    .col(string(MarketInfo::DeveloperName).not_null().default(""))
                    .col(string(MarketInfo::DeveloperEmail).not_null().default(""))
                    .col(string(MarketInfo::SupportUrl).not_null().default(""))
                    .col(string(MarketInfo::HomepageUrl).not_null().default(""))
                    .col(array(MarketInfo::Permissions, ColumnType::Text).not_null().default(Expr::cust("ARRAY[]::text[]")))
                    .col(integer(MarketInfo::InstallCount).not_null().default(0))
                    .col(double(MarketInfo::RatingAvg).not_null().default(0.0))
                    .col(integer(MarketInfo::RatingCount).not_null().default(0))
                    .col(boolean(MarketInfo::IsFeatured).not_null().default(false))
                    .col(timestamp_with_time_zone(MarketInfo::CreatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .col(timestamp_with_time_zone(MarketInfo::UpdatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(MarketInfo::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum MarketInfo {
    Table,
    AppId,
    AppCategory,
    IconFileId,
    Screenshots,
    ShortDescription,
    DetailedDescription,
    DeveloperName,
    DeveloperEmail,
    SupportUrl,
    HomepageUrl,
    Permissions,
    InstallCount,
    RatingAvg,
    RatingCount,
    IsFeatured,
    CreatedAt,
    UpdatedAt,
}
