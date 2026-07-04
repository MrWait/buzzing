use sea_orm::entity::prelude::*;
pub use super::_entities::user2_calendars::{ActiveModel, Model, Entity};
pub type User2Calendars = Entity;

#[async_trait::async_trait]
impl ActiveModelBehavior for ActiveModel {}

impl Model {}

impl ActiveModel {}

impl Entity {}
