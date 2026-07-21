use sea_orm_migration::{prelude::*, schema::*};

fn pk<I: IntoIden>(col: I) -> ColumnDef {
    ColumnDef::new(col).big_integer().not_null().primary_key().take()
}

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(InviteLinks::Table)
                    .if_not_exists()
                    .col(pk(InviteLinks::Id))
                    .col(big_integer(InviteLinks::ChatId))
                    .col(string(InviteLinks::Code))
                    .col(big_integer(InviteLinks::CreatedBy))
                    .col(
                        ColumnDef::new(InviteLinks::CreatedAt)
                            .timestamp_with_time_zone()
                            .not_null()
                            .default(Expr::current_timestamp()),
                    )
                    .col(
                        ColumnDef::new(InviteLinks::ExpiresAt)
                            .timestamp_with_time_zone()
                            .null(),
                    )
                    .col(
                        ColumnDef::new(InviteLinks::MaxUses)
                            .integer()
                            .not_null()
                            .default(0),
                    )
                    .col(
                        ColumnDef::new(InviteLinks::UseCount)
                            .integer()
                            .not_null()
                            .default(0),
                    )
                    .col(
                        ColumnDef::new(InviteLinks::IsActive)
                            .boolean()
                            .not_null()
                            .default(true),
                    )
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .table(InviteLinks::Table)
                    .unique()
                    .col(InviteLinks::Code)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .table(InviteLinks::Table)
                    .col(InviteLinks::ChatId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(InviteLinks::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum InviteLinks {
    Table,
    Id,
    ChatId,
    Code,
    CreatedBy,
    CreatedAt,
    ExpiresAt,
    MaxUses,
    UseCount,
    IsActive,
}
