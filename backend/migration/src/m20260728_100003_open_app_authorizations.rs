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
                    .table(Authorizations::Table)
                    .col(crate::pk(Authorizations::Id))
                    .col(big_integer(Authorizations::AppId).not_null())
                    .col(big_integer(Authorizations::UserId).not_null())
                    .col(big_integer(Authorizations::TenantId).not_null())
                    .col(array(Authorizations::Scopes, ColumnType::Text).not_null().default(Expr::cust("ARRAY[]::text[]")))
                    .col(small_integer(Authorizations::Status).not_null().default(1))
                    .col(timestamp_with_time_zone(Authorizations::CreatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .col(timestamp_with_time_zone(Authorizations::UpdatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx-oauth-app_user")
                    .table(Authorizations::Table)
                    .col(Authorizations::AppId)
                    .col(Authorizations::UserId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Authorizations::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Authorizations {
    Table,
    Id,
    AppId,
    UserId,
    TenantId,
    Scopes,
    Status,
    CreatedAt,
    UpdatedAt,
}
