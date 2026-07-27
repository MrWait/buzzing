use loco_rs::schema::table_auto_tz;
use sea_orm_migration::sea_orm::Statement;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        // 1. documents 扩展列
        manager
            .alter_table(
                Table::alter()
                    .table(Documents::Table)
                    .add_column_if_not_exists(big_integer_null(Documents::ParentId))
                    .add_column_if_not_exists(timestamp_with_time_zone_null(Documents::TrashedAt))
                    .add_column_if_not_exists(string_null(Documents::Icon))
                    .add_column_if_not_exists(string_null(Documents::Cover))
                    .add_column_if_not_exists(text_null(Documents::PlainText))
                    .to_owned(),
            )
            .await?;

        // 2. document_stars 表
        manager
            .create_table(
                table_auto_tz(DocumentStars::Table)
                    .col(crate::pk(DocumentStars::Id))
                    .col(big_integer(DocumentStars::UserId))
                    .col(big_integer(DocumentStars::DocumentId))
                    .col(string_null(DocumentStars::GroupName))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("ux_document_stars_user_doc")
                    .table(DocumentStars::Table)
                    .col(DocumentStars::UserId)
                    .col(DocumentStars::DocumentId)
                    .unique()
                    .to_owned(),
            )
            .await?;

        // 3. document_visits 表
        manager
            .create_table(
                table_auto_tz(DocumentVisits::Table)
                    .col(crate::pk(DocumentVisits::Id))
                    .col(big_integer(DocumentVisits::UserId))
                    .col(big_integer(DocumentVisits::DocumentId))
                    .col(big_integer(DocumentVisits::VisitedAt))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("ux_document_visits_user_doc")
                    .table(DocumentVisits::Table)
                    .col(DocumentVisits::UserId)
                    .col(DocumentVisits::DocumentId)
                    .unique()
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_document_visits_user_time")
                    .table(DocumentVisits::Table)
                    .col(DocumentVisits::UserId)
                    .col((DocumentVisits::VisitedAt, IndexOrder::Desc))
                    .to_owned(),
            )
            .await?;

        // 4. 原生 SQL：索引 + tsvector
        let db = manager.get_connection();
        let backend = manager.get_database_backend();
        let stmts = [
            "CREATE INDEX IF NOT EXISTS idx_documents_parent \
             ON documents(parent_id)",
            "CREATE INDEX IF NOT EXISTS idx_documents_trashed \
             ON documents(trashed_at) WHERE trashed_at IS NOT NULL",
            "ALTER TABLE documents \
             ADD COLUMN IF NOT EXISTS search_tsv tsvector \
             GENERATED ALWAYS AS ( \
                setweight(to_tsvector('simple', coalesce(title, '')), 'A') || \
                setweight(to_tsvector('simple', coalesce(plain_text, '')), 'B') \
             ) STORED",
            "CREATE INDEX IF NOT EXISTS idx_documents_search \
             ON documents USING GIN(search_tsv)",
        ];
        for sql in stmts {
            db.execute(Statement::from_string(backend, sql.to_owned())).await?;
        }
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let db = manager.get_connection();
        let backend = manager.get_database_backend();
        for sql in [
            "DROP INDEX IF EXISTS idx_documents_search",
            "ALTER TABLE documents DROP COLUMN IF EXISTS search_tsv",
            "DROP INDEX IF EXISTS idx_documents_trashed",
            "DROP INDEX IF EXISTS idx_documents_parent",
        ] {
            db.execute(Statement::from_string(backend, sql.to_owned())).await?;
        }
        manager
            .drop_table(Table::drop().table(DocumentVisits::Table).to_owned())
            .await?;
        manager
            .drop_table(Table::drop().table(DocumentStars::Table).to_owned())
            .await?;
        manager
            .alter_table(
                Table::alter()
                    .table(Documents::Table)
                    .drop_column(Documents::ParentId)
                    .drop_column(Documents::TrashedAt)
                    .drop_column(Documents::Icon)
                    .drop_column(Documents::Cover)
                    .drop_column(Documents::PlainText)
                    .to_owned(),
            )
            .await?;
        Ok(())
    }
}

#[derive(DeriveIden)]
enum Documents {
    Table,
    ParentId,
    TrashedAt,
    Icon,
    Cover,
    PlainText,
}

#[derive(DeriveIden)]
enum DocumentStars {
    Table,
    Id,
    UserId,
    DocumentId,
    GroupName,
}

#[derive(DeriveIden)]
enum DocumentVisits {
    Table,
    Id,
    UserId,
    DocumentId,
    VisitedAt,
}
