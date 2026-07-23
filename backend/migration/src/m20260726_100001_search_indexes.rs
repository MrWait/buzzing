use sea_orm_migration::sea_orm::Statement;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let db = manager.get_connection();
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "CREATE EXTENSION IF NOT EXISTS pg_trgm".to_owned(),
        ))
        .await?;
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "CREATE INDEX IF NOT EXISTS idx_messages_summary_trgm ON messages USING gin (summary gin_trgm_ops)"
                .to_owned(),
        ))
        .await?;
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "CREATE INDEX IF NOT EXISTS idx_chats_name_trgm ON chats USING gin (name gin_trgm_ops)"
                .to_owned(),
        ))
        .await?;
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "CREATE INDEX IF NOT EXISTS idx_users_name_trgm ON users USING gin (name gin_trgm_ops)"
                .to_owned(),
        ))
        .await?;
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "CREATE INDEX IF NOT EXISTS idx_files_name_trgm ON files USING gin (file_name gin_trgm_ops)"
                .to_owned(),
        ))
        .await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let db = manager.get_connection();
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "DROP INDEX IF EXISTS idx_messages_summary_trgm".to_owned(),
        ))
        .await?;
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "DROP INDEX IF EXISTS idx_chats_name_trgm".to_owned(),
        ))
        .await?;
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "DROP INDEX IF EXISTS idx_users_name_trgm".to_owned(),
        ))
        .await?;
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "DROP INDEX IF EXISTS idx_files_name_trgm".to_owned(),
        ))
        .await?;
        Ok(())
    }
}
