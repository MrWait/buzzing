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
                    .table(OutgoingWebhooks::Table)
                    .col(crate::pk(OutgoingWebhooks::Id))
                    .col(big_integer(OutgoingWebhooks::AppId).not_null())
                    .col(big_integer(OutgoingWebhooks::ChatId).not_null())
                    .col(string(OutgoingWebhooks::Name).not_null())
                    .col(string(OutgoingWebhooks::Command).not_null())
                    .col(string(OutgoingWebhooks::WebhookUrl).not_null())
                    .col(string(OutgoingWebhooks::WebhookSecret).not_null())
                    .col(small_integer(OutgoingWebhooks::Status).not_null().default(1))
                    .col(timestamp_with_time_zone(OutgoingWebhooks::CreatedAt).not_null().default(SimpleExpr::from("NOW()")))
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx-outgoing_app")
                    .table(OutgoingWebhooks::Table)
                    .col(OutgoingWebhooks::AppId)
                    .to_owned(),
            )
            .await?;

        manager
            .create_index(
                Index::create()
                    .name("idx-outgoing_chat")
                    .table(OutgoingWebhooks::Table)
                    .col(OutgoingWebhooks::ChatId)
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(OutgoingWebhooks::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum OutgoingWebhooks {
    Table,
    Id,
    AppId,
    ChatId,
    Name,
    Command,
    WebhookUrl,
    WebhookSecret,
    Status,
    CreatedAt,
}
