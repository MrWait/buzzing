use loco_rs::prelude::*;
use sea_orm_migration::sea_orm::Statement;
use sea_orm_migration::prelude::*;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let db = manager.get_connection();
        let backend = manager.get_database_backend();
        db.execute(Statement::from_string(backend,
            "ALTER TABLE wikis ADD COLUMN IF NOT EXISTS visibility INT NOT NULL DEFAULT 0"
        )).await?;
        db.execute(Statement::from_string(backend,
            "ALTER TABLE wikis ADD COLUMN IF NOT EXISTS allow_external_share BOOLEAN NOT NULL DEFAULT TRUE"
        )).await?;
        db.execute(Statement::from_string(backend,
            "ALTER TABLE wikis ADD COLUMN IF NOT EXISTS reader_permission INT NOT NULL DEFAULT 0"
        )).await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let db = manager.get_connection();
        let backend = manager.get_database_backend();
        db.execute(Statement::from_string(backend,
            "ALTER TABLE wikis DROP COLUMN IF EXISTS visibility"
        )).await?;
        db.execute(Statement::from_string(backend,
            "ALTER TABLE wikis DROP COLUMN IF EXISTS allow_external_share"
        )).await?;
        db.execute(Statement::from_string(backend,
            "ALTER TABLE wikis DROP COLUMN IF EXISTS reader_permission"
        )).await?;
        Ok(())
    }
}
