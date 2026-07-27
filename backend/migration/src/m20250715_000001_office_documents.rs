use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Documents::Table)
                    .col(crate::pk(Documents::Id))
                    .col(big_integer(Documents::TenantId))
                    .col(big_integer(Documents::Creator))
                    .col(string(Documents::Title))
                    .col(integer(Documents::DocType))
                    .col(big_integer(Documents::Version))
                    .col(blob(Documents::Content))
                    .col(big_integer(Documents::WikiId))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-documents-wiki")
                    .table(Documents::Table)
                    .col(Documents::WikiId)
                    .to_owned(),
            )
            .await?;

        manager
            .create_table(
                Table::create()
                    .table(DocumentMembers::Table)
                    .col(big_integer(DocumentMembers::DocId))
                    .col(big_integer(DocumentMembers::UserId))
                    .col(integer(DocumentMembers::Role))
                    .col(big_integer(DocumentMembers::JoinedAt))
                    .primary_key(
                        Index::create()
                            .col(DocumentMembers::DocId)
                            .col(DocumentMembers::UserId),
                    )
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-docmembers-user")
                    .table(DocumentMembers::Table)
                    .col(DocumentMembers::UserId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(DocumentMembers::Table).to_owned())
            .await?;
        manager
            .drop_table(Table::drop().table(Documents::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Documents {
    Table,
    Id,
    TenantId,
    Creator,
    Title,
    DocType,
    Version,
    Content,
    WikiId,
}

#[derive(DeriveIden)]
enum DocumentMembers {
    Table,
    DocId,
    UserId,
    Role,
    JoinedAt,
}
