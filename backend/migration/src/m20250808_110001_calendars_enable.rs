use sea_orm_migration::sea_orm::Statement;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Calendars::Table)
                    .add_column_if_not_exists(boolean(Calendars::Enable).default(true))
                    .to_owned(),
            )
            .await?;
        let db = manager.get_connection();
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "CREATE EXTENSION IF NOT EXISTS pg_trgm".to_owned(),
        ))
        .await?;
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "CREATE INDEX IF NOT EXISTS idx_calendars_name_trgm ON calendars USING gin (name gin_trgm_ops)"
                .to_owned(),
        ))
        .await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Calendars::Table)
                    .drop_column(Calendars::Enable)
                    .to_owned(),
            )
            .await?;
        let db = manager.get_connection();
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "DROP INDEX IF EXISTS idx_calendars_name_trgm".to_owned(),
        ))
        .await?;
        Ok(())
    }
}

#[derive(DeriveIden)]
enum Calendars {
    Table,
    Enable,
}
