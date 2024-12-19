use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Tenants::Table)
                    .col(crate::pk(Tenants::Id))
                    .col(string(Tenants::Name))
                    .col(big_integer(Tenants::RootDeptId))
                    .col(big_unsigned(Tenants::OwnerId))
                    .col(array(Tenants::Managers, ColumnType::BigUnsigned))
                    .col(big_unsigned(Tenants::Version))
                    .col(blob(Tenants::Extra))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Tenants::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Tenants {
    Table,
    Id,
    Name,
    RootDeptId,
    OwnerId,
    Managers,
    Version,
    Extra,
}
