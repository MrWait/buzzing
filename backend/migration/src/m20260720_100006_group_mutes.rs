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
                    .table(GroupMutes::Table)
                    .if_not_exists()
                    .col(pk(GroupMutes::Id))
                    .col(big_integer(GroupMutes::ChatId))
                    .col(big_integer(GroupMutes::MemberId))
                    .col(
                        ColumnDef::new(GroupMutes::MutedUntil)
                            .timestamp_with_time_zone()
                            .not_null(),
                    )
                    .col(
                        ColumnDef::new(GroupMutes::CreatedAt)
                            .timestamp_with_time_zone()
                            .not_null()
                            .default(Expr::current_timestamp()),
                    )
                    .col(
                        ColumnDef::new(GroupMutes::UpdatedAt)
                            .timestamp_with_time_zone()
                            .not_null()
                            .default(Expr::current_timestamp()),
                    )
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .table(GroupMutes::Table)
                    .unique()
                    .col(GroupMutes::ChatId)
                    .col(GroupMutes::MemberId)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .table(GroupMutes::Table)
                    .col(GroupMutes::ChatId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(GroupMutes::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum GroupMutes {
    Table,
    Id,
    ChatId,
    MemberId,
    MutedUntil,
    CreatedAt,
    UpdatedAt,
}
