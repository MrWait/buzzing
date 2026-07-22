use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Messages::Table)
                    .add_column_if_not_exists(
                        ColumnDef::new(Messages::ThreadRootId)
                            .big_integer()
                            .not_null()
                            .default(0),
                    )
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .table(Messages::Table)
                    .col(Messages::ChatId)
                    .col(Messages::ThreadRootId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Messages::Table)
                    .drop_column(Messages::ThreadRootId)
                    .to_owned(),
            )
            .await
    }
}

#[derive(DeriveIden)]
enum Messages {
    Table,
    ChatId,
    ThreadRootId,
}
