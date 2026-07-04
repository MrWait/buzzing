use sea_orm::entity::prelude::*;
pub use super::_entities::schedule_reminders::{ActiveModel, Model, Entity};
pub type ScheduleReminders = Entity;

#[async_trait::async_trait]
impl ActiveModelBehavior for ActiveModel {}

impl Model {}

impl ActiveModel {}

impl Entity {}
