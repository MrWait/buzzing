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
                    .table(OpenApps::Table)
                    .col(crate::pk(OpenApps::Id))
                    .col(big_integer(OpenApps::TenantId).not_null())
                    .col(string(OpenApps::Name).not_null().default(""))
                    .col(string(OpenApps::Description).not_null().default(""))
                    .col(small_integer(OpenApps::AppType).not_null().default(1))
                    .col(string(OpenApps::AppId).not_null())
                    .col(string(OpenApps::AppSecret).not_null())
                    .col(array(OpenApps::Scopes, ColumnType::Text).not_null().default(SimpleExpr::from("'{}'")))
                    .col(big_integer(OpenApps::OwnerId).not_null())
                    .col(small_integer(OpenApps::Status).not_null().default(1))
                    .col(timestamp(OpenApps::CreatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .col(timestamp(OpenApps::UpdatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .col(timestamp(OpenApps::DeletedAt).null())
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-open_apps-app_id")
                    .table(OpenApps::Table)
                    .col(OpenApps::AppId)
                    .unique()
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-open_apps-tenant")
                    .table(OpenApps::Table)
                    .col(OpenApps::TenantId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(OpenApps::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum OpenApps {
    Table,
    Id,
    TenantId,
    Name,
    Description,
    AppType,
    AppId,
    AppSecret,
    Scopes,
    OwnerId,
    Status,
    CreatedAt,
    UpdatedAt,
    DeletedAt,
}
