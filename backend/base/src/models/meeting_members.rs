use sea_orm::entity::prelude::*;
pub use super::_entities::meeting_members::{ActiveModel, Entity, Model};
pub type MeetingMembers = Entity;

#[async_trait::async_trait]
impl ActiveModelBehavior for ActiveModel {}

impl Model {}
impl ActiveModel {}
impl Entity {}
