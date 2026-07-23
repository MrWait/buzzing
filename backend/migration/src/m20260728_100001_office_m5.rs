use loco_rs::schema::table_auto_tz;
use sea_orm_migration::sea_orm::Statement;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(DocumentVersions::Table)
                    .col(crate::pk(DocumentVersions::Id))
                    .col(big_integer(DocumentVersions::DocumentId))
                    .col(integer(DocumentVersions::VersionNumber))
                    .col(string(DocumentVersions::Title))
                    .col(string_null(DocumentVersions::Description))
                    .col(blob(DocumentVersions::YjsSnapshot))
                    .col(text_null(DocumentVersions::PlainText))
                    .col(big_integer(DocumentVersions::CreatorId))
                    .col(boolean(DocumentVersions::IsMinor).default(false))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_doc_versions_doc")
                    .table(DocumentVersions::Table)
                    .col(DocumentVersions::DocumentId)
                    .col((DocumentVersions::VersionNumber, IndexOrder::Desc))
                    .to_owned(),
            )
            .await?;
        let db = manager.get_connection();
        let backend = manager.get_database_backend();
        db.execute(Statement::from_string(
            backend,
            "CREATE INDEX IF NOT EXISTS idx_doc_versions_doc_id \
             ON document_versions(document_id)".to_owned(),
        ))
        .await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(DocumentVersions::Table).to_owned())
            .await?;
        Ok(())
    }
}

#[derive(DeriveIden)]
enum DocumentVersions {
    Table,
    Id,
    DocumentId,
    VersionNumber,
    Title,
    Description,
    YjsSnapshot,
    PlainText,
    CreatorId,
    IsMinor,
}
