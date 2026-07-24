use sea_orm_migration::prelude::*;
use sea_orm_migration::schema::*;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(Reviews::Table)
                    .col(crate::pk(Reviews::Id))
                    .col(big_integer(Reviews::AppId).not_null())
                    .col(big_integer(Reviews::UserId).not_null())
                    .col(big_integer(Reviews::TenantId).not_null())
                    .col(small_integer(Reviews::Rating).not_null().default(5))
                    .col(text_null(Reviews::Content))
                    .col(text_null(Reviews::ReplyContent))
                    .col(timestamp_with_time_zone_null(Reviews::ReplyAt))
                    .col(timestamp_with_time_zone(Reviews::CreatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .col(timestamp_with_time_zone(Reviews::UpdatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx-reviews_app_user")
                    .table(Reviews::Table)
                    .col(Reviews::AppId)
                    .col(Reviews::UserId)
                    .col(Reviews::TenantId)
                    .unique()
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Reviews::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Reviews {
    Table,
    Id,
    AppId,
    UserId,
    TenantId,
    Rating,
    Content,
    ReplyContent,
    ReplyAt,
    CreatedAt,
    UpdatedAt,
}
