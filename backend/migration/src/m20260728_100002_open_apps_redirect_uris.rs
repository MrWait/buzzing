use sea_orm_migration::prelude::*;
use sea_orm_migration::schema::*;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Alias::new("open_apps"))
                    .add_column(array(Alias::new("redirect_uris"), ColumnType::Text).not_null().default(Expr::cust("ARRAY[]::text[]")))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Alias::new("open_apps"))
                    .drop_column(Alias::new("redirect_uris"))
                    .to_owned(),
            )
            .await
    }
}

#[derive(DeriveIden)]
enum OpenApps {
    Table,
    RedirectUris,
}
