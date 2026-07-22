use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Chats::Table)
                    .add_column_if_not_exists(
                        ColumnDef::new(Chats::AllowAtAll)
                            .boolean()
                            .not_null()
                            .default(true),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Chats::Table)
                    .drop_column(Chats::AllowAtAll)
                    .to_owned(),
            )
            .await
    }
}

#[derive(DeriveIden)]
enum Chats {
    Table,
    AllowAtAll,
}
