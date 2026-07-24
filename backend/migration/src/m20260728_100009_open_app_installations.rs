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
                    .table(Installations::Table)
                    .col(crate::pk(Installations::Id))
                    .col(big_integer(Installations::AppId).not_null())
                    .col(big_integer(Installations::TenantId).not_null())
                    .col(big_integer(Installations::InstallerId).not_null())
                    .col(array(Installations::Scopes, ColumnType::Text).not_null().default(Expr::cust("ARRAY[]::text[]")))
                    .col(small_integer(Installations::Status).not_null().default(1))
                    .col(timestamp_with_time_zone(Installations::InstalledAt).not_null().default(SimpleExpr::from("NOW()")))
                    .col(timestamp_with_time_zone(Installations::UpdatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .col(timestamp_with_time_zone_null(Installations::UninstalledAt))
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx-installations_tenant")
                    .table(Installations::Table)
                    .col(Installations::TenantId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Installations::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Installations {
    Table,
    Id,
    AppId,
    TenantId,
    InstallerId,
    Scopes,
    Status,
    InstalledAt,
    UpdatedAt,
    UninstalledAt,
}
