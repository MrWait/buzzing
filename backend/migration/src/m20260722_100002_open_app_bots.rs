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
                    .table(OpenAppBots::Table)
                    .col(crate::pk(OpenAppBots::Id))
                    .col(big_integer(OpenAppBots::AppId).not_null())
                    .col(big_integer(OpenAppBots::BotUserId).not_null())
                    .col(string(OpenAppBots::WebhookUrl).not_null().default(""))
                    .col(string(OpenAppBots::WebhookSecret).not_null().default(""))
                    .col(array(OpenAppBots::EventTypes, ColumnType::Text).not_null().default(Expr::cust("ARRAY[]::text[]")))
                    .col(small_integer(OpenAppBots::Status).not_null().default(1))
                    .col(timestamp_with_time_zone(OpenAppBots::CreatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                Index::create()
                    .name("idx-open_app_bots-app")
                    .table(OpenAppBots::Table)
                    .col(OpenAppBots::AppId)
                    .unique()
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(OpenAppBots::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum OpenAppBots {
    Table,
    Id,
    AppId,
    BotUserId,
    WebhookUrl,
    WebhookSecret,
    EventTypes,
    Status,
    CreatedAt,
}
