use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let table = table_auto_tz(Users::Table)
            .col(crate::pk(Users::Id))
            .col(uuid(Users::Pid))
            .col(big_integer(Users::AId))
            .col(string(Users::ApiKey).unique_key())
            .col(string(Users::Name))
            .col(big_integer(Users::TenantId))
            .col(tiny_integer(Users::Type))
            .col(tiny_integer(Users::Status))
            .col(string_null(Users::Avatar))
            .col(tiny_integer(Users::TenantPermision))
            .col(big_integer(Users::DeptId))
            .col(big_integer(Users::Version))
            .col(blob(Users::Extra))
            .to_owned();
        manager.create_table(table).await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Users::Table).to_owned())
            .await
    }
}

#[derive(Iden)]
pub enum Users {
    Table,
    Id,
    Pid,
    AId,
    TenantId,
    Name,
    ApiKey,
    Type,
    Status,
    Avatar,
    TenantPermision,
    DeptId,
    Version,
    Extra,
}
