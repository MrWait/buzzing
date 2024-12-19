use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Depts::Table)
                    .col(crate::pk(Depts::Id))
                    .col(big_integer(Depts::ParentId))
                    .col(big_integer(Depts::TenantId))
                    .col(string(Depts::Name))
                    .col(array(Depts::MemberIds, ColumnType::BigInteger))
                    .col(array(Depts::SubIds, ColumnType::BigInteger))
                    .col(big_integer(Depts::Version))
                    .col(blob(Depts::Extra))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Depts::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Depts {
    Table,
    Id,
    ParentId,
    TenantId,
    Name,
    MemberIds,
    SubIds,
    Version,
    Extra,
}
