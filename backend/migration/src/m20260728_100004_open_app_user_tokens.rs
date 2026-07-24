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
                    .table(UserTokens::Table)
                    .col(crate::pk(UserTokens::Id))
                    .col(big_integer(UserTokens::AuthorizationId).not_null())
                    .col(string(UserTokens::AccessToken).not_null())
                    .col(string(UserTokens::RefreshToken).not_null())
                    .col(array(UserTokens::Scopes, ColumnType::Text).not_null().default(Expr::cust("ARRAY[]::text[]")))
                    .col(timestamp_with_time_zone(UserTokens::AccessExpireAt).not_null())
                    .col(timestamp_with_time_zone(UserTokens::RefreshExpireAt).not_null())
                    .col(timestamp_with_time_zone(UserTokens::CreatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx-token-authorization")
                    .table(UserTokens::Table)
                    .col(UserTokens::AuthorizationId)
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx-token-access")
                    .table(UserTokens::Table)
                    .col(UserTokens::AccessToken)
                    .unique()
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx-token-refresh")
                    .table(UserTokens::Table)
                    .col(UserTokens::RefreshToken)
                    .unique()
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(UserTokens::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum UserTokens {
    Table,
    Id,
    AuthorizationId,
    AccessToken,
    RefreshToken,
    Scopes,
    AccessExpireAt,
    RefreshExpireAt,
    CreatedAt,
}
