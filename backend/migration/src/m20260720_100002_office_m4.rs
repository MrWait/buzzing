use loco_rs::schema::table_auto_tz;
use sea_orm_migration::sea_orm::Statement;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        // 1. document_shares 新建
        manager
            .create_table(
                table_auto_tz(DocumentShares::Table)
                    .col(crate::pk(DocumentShares::Id))
                    .col(big_integer(DocumentShares::DocumentId))
                    .col(string(DocumentShares::Token))
                    .col(big_integer(DocumentShares::CreatorId))
                    .col(small_integer(DocumentShares::Role).default(0))
                    .col(string_null(DocumentShares::PasswordHash))
                    .col(timestamp_with_time_zone_null(DocumentShares::ExpiresAt))
                    .col(integer_null(DocumentShares::MaxVisits))
                    .col(integer(DocumentShares::VisitCount).default(0))
                    .col(timestamp_with_time_zone_null(DocumentShares::RevokedAt))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("ux_document_shares_token")
                    .table(DocumentShares::Table)
                    .col(DocumentShares::Token)
                    .unique()
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_document_shares_doc")
                    .table(DocumentShares::Table)
                    .col(DocumentShares::DocumentId)
                    .to_owned(),
            )
            .await?;

        // 2. document_members 补齐
        let db = manager.get_connection();
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "CREATE INDEX IF NOT EXISTS idx_document_members_user \
             ON document_members(user_id)"
                .to_owned(),
        ))
        .await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let db = manager.get_connection();
        db.execute(Statement::from_string(
            manager.get_database_backend(),
            "DROP INDEX IF EXISTS idx_document_members_user".to_owned(),
        ))
        .await?;
        manager
            .drop_table(Table::drop().table(DocumentShares::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum DocumentShares {
    Table,
    Id,
    DocumentId,
    Token,
    CreatorId,
    Role,
    PasswordHash,
    ExpiresAt,
    MaxVisits,
    VisitCount,
    RevokedAt,
}
