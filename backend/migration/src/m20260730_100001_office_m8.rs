use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(DocumentMentions::Table)
                    .if_not_exists()
                    .col(crate::pk(DocumentMentions::Id))
                    .col(big_integer(DocumentMentions::DocId))
                    .col(string_len(DocumentMentions::MentionedType, 20))
                    .col(string(DocumentMentions::MentionedId))
                    .col(big_integer(DocumentMentions::MentionedBy))
                    .col(big_integer(DocumentMentions::CreatedAt))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx_doc_mentions_doc")
                    .table(DocumentMentions::Table)
                    .col(DocumentMentions::DocId)
                    .to_owned(),
            )
            .await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(DocumentMentions::Table).to_owned())
            .await?;
        Ok(())
    }
}

#[derive(DeriveIden)]
enum DocumentMentions {
    Table,
    Id,
    DocId,
    MentionedType,
    MentionedId,
    MentionedBy,
    CreatedAt,
}
