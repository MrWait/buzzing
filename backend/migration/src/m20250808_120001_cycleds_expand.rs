use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Cycleds::Table)
                    .add_column_if_not_exists(big_integer_null(Cycleds::ExpandStart))
                    .add_column_if_not_exists(big_integer_null(Cycleds::ExpandEnd))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Cycleds::Table)
                    .drop_column(Cycleds::ExpandStart)
                    .drop_column(Cycleds::ExpandEnd)
                    .to_owned(),
            )
            .await
    }
}

#[derive(DeriveIden)]
enum Cycleds {
    Table,
    ExpandStart,
    ExpandEnd,
}
