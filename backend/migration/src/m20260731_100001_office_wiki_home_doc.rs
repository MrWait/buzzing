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
        // wikis 增加 home_doc_id 字段（引用文档首页）
        db.execute(Statement::from_string(backend,
            "ALTER TABLE wikis ADD COLUMN IF NOT EXISTS home_doc_id BIGINT"
        )).await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let db = manager.get_connection();
        let backend = manager.get_database_backend();
        db.execute(Statement::from_string(backend,
            "ALTER TABLE wikis DROP COLUMN IF EXISTS home_doc_id"
        )).await?;
        Ok(())
    }
}
