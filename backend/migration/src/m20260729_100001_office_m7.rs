use loco_rs::schema::table_auto_tz;
use sea_orm_migration::sea_orm::Statement;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        // wikis 表
        manager
            .create_table(
                table_auto_tz(Wikis::Table)
                    .col(crate::pk(Wikis::Id))
                    .col(big_integer(Wikis::TenantId))
                    .col(string_len(Wikis::Name, 255))
                    .col(string_null(Wikis::Description))
                    .col(string_len_null(Wikis::Icon, 50))
                    .col(string_len_null(Wikis::Cover, 500))
                    .col(big_integer(Wikis::CreatorId))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_wikis_tenant")
                    .table(Wikis::Table)
                    .col(Wikis::TenantId)
                    .to_owned(),
            )
            .await?;

        // wiki_members 表
        manager
            .create_table(
                Table::create()
                    .table(WikiMembers::Table)
                    .if_not_exists()
                    .col(big_integer(WikiMembers::WikiId))
                    .col(big_integer(WikiMembers::UserId))
                    .col(small_integer(WikiMembers::Role).default(1))
                    .col(big_integer(WikiMembers::JoinedAt))
                    .primary_key(
                        Index::create()
                            .col(WikiMembers::WikiId)
                            .col(WikiMembers::UserId),
                    )
                    .to_owned(),
            )
            .await?;

        // wiki_pins 表
        manager
            .create_table(
                Table::create()
                    .table(WikiPins::Table)
                    .if_not_exists()
                    .col(crate::pk(WikiPins::Id))
                    .col(big_integer(WikiPins::WikiId))
                    .col(big_integer(WikiPins::DocId))
                    .col(big_integer(WikiPins::PinnedBy))
                    .col(big_integer(WikiPins::CreatedAt))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_wiki_pins_wiki")
                    .table(WikiPins::Table)
                    .col(WikiPins::WikiId)
                    .to_owned(),
            )
            .await?;

        // documents 新增 wiki_id（替代 document_spaces.wiki_id，去掉空间层）
        let db = manager.get_connection();
        let backend = manager.get_database_backend();
        db.execute(Statement::from_string(backend,
            "ALTER TABLE documents ADD COLUMN IF NOT EXISTS wiki_id BIGINT REFERENCES wikis(id)"
        )).await?;
        db.execute(Statement::from_string(backend,
            "CREATE INDEX IF NOT EXISTS idx_documents_wiki_id ON documents(wiki_id)"
        )).await?;

        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(WikiPins::Table).to_owned())
            .await?;
        manager
            .drop_table(Table::drop().table(WikiMembers::Table).to_owned())
            .await?;
        manager
            .drop_table(Table::drop().table(Wikis::Table).to_owned())
            .await?;
        let db = manager.get_connection();
        let backend = manager.get_database_backend();
        db.execute(Statement::from_string(backend,
            "DROP INDEX IF EXISTS idx_documents_wiki_id"
        )).await?;
        db.execute(Statement::from_string(backend,
            "ALTER TABLE documents DROP COLUMN IF EXISTS wiki_id"
        )).await?;
        Ok(())
    }
}

#[derive(DeriveIden)]
enum Wikis {
    Table,
    Id,
    TenantId,
    Name,
    Description,
    Icon,
    Cover,
    CreatorId,
}

#[derive(DeriveIden)]
enum WikiMembers {
    Table,
    WikiId,
    UserId,
    Role,
    JoinedAt,
}

#[derive(DeriveIden)]
enum WikiPins {
    Table,
    Id,
    WikiId,
    DocId,
    PinnedBy,
    CreatedAt,
}
