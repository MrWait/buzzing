use loco_rs::prelude::*;

use super::_entities::messages;

pub type Messages = messages::Entity;

impl ActiveModelBehavior for messages::ActiveModel {
    // extend activemodel below (keep comment for generators)
}
