use loco_rs::schema::table_auto_tz;
use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                table_auto_tz(Accounts::Table)
                    .col(crate::pk(Accounts::Id))
                    .col(string_uniq(Accounts::Phone))
                    .col(string(Accounts::Name))
                    .col(string(Accounts::Password))
                    .col(string_null(Accounts::ResetToken))
                    .col(timestamp_with_time_zone_null(Accounts::ResetSentAt))
                    .col(string_null(Accounts::VerificationToken))
                    .col(string_null(Accounts::PhoneVerificationToken))
                    .col(timestamp_with_time_zone_null(
                        Accounts::PhoneVerificationSentAt,
                    ))
                    .col(timestamp_with_time_zone_null(Accounts::PhoneVerifiedAt))
                    .col(string_null(Accounts::Avatar))
                    .col(big_integer(Accounts::Version))
                    .col(binary(Accounts::Extra))
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Accounts::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Accounts {
    Table,
    Id,
    Phone,
    Name,
    Password,
    ResetToken,
    ResetSentAt,
    VerificationToken,
    PhoneVerificationToken,
    PhoneVerificationSentAt,
    PhoneVerifiedAt,
    Avatar,
    Version,
    Extra,
}
