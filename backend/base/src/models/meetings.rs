use sea_orm::entity::prelude::*;
pub use super::_entities::meetings::{ActiveModel, Entity, Model};
pub type Meetings = Entity;

#[async_trait::async_trait]
impl ActiveModelBehavior for ActiveModel {
    async fn before_save<C>(self, _db: &C, insert: bool) -> std::result::Result<Self, DbErr>
    where
        C: ConnectionTrait,
    {
        if !insert && self.updated_at.is_unchanged() {
            let mut this = self;
            this.updated_at = sea_orm::ActiveValue::Set(chrono::Utc::now().timestamp());
            Ok(this)
        } else {
            Ok(self)
        }
    }
}

impl Model {}
impl ActiveModel {}
impl Entity {}
