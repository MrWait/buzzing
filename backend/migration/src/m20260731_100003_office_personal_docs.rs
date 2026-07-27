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
        // 1. 使 wiki_id 可空（个人文档 wiki_id = NULL）
        db.execute(Statement::from_string(backend,
            "ALTER TABLE documents ALTER COLUMN wiki_id DROP NOT NULL"
        )).await?;
        // 2. 删除 is_default 字段
        db.execute(Statement::from_string(backend,
            "ALTER TABLE wikis DROP COLUMN IF EXISTS is_default"
        )).await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let db = manager.get_connection();
        let backend = manager.get_database_backend();
        db.execute(Statement::from_string(backend,
            "ALTER TABLE documents ALTER COLUMN wiki_id SET NOT NULL"
        )).await?;
        db.execute(Statement::from_string(backend,
            "ALTER TABLE wikis ADD COLUMN is_default BOOLEAN NOT NULL DEFAULT FALSE"
        )).await?;
        Ok(())
    }
}
