use sea_orm_migration::prelude::*;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(Files::Table)
                    .col(crate::pk(Files::Id))
                    .col(big_integer(Files::UserId).not_null())
                    .col(big_integer(Files::DocId).null())
                    .col(string(Files::FileName).not_null())
                    .col(big_integer(Files::FileSize).not_null().default(0))
                    .col(string(Files::MimeType).not_null().default("application/octet-stream"))
                    .col(string(Files::Ext).not_null().default(""))
                    .col(string(Files::StorageKey).not_null())
                    .col(string(Files::Md5).null())
                    .col(string(Files::Category).not_null().default("file"))
                    .col(big_integer(Files::CreatedAt).not_null())
                    .col(big_integer(Files::DeletedAt).null())
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-files-user")
                    .table(Files::Table)
                    .col(Files::UserId)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-files-doc")
                    .table(Files::Table)
                    .col(Files::DocId)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-files-category")
                    .table(Files::Table)
                    .col(Files::Category)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Files::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Files {
    Table,
    Id,
    UserId,
    DocId,
    FileName,
    FileSize,
    MimeType,
    Ext,
    StorageKey,
    Md5,
    Category,
    CreatedAt,
    DeletedAt,
}

fn big_integer<I: IntoIden>(col: I) -> ColumnDef {
    ColumnDef::new(col).big_integer().take()
}

fn string<I: IntoIden>(col: I) -> ColumnDef {
    ColumnDef::new(col).string().take()
}
