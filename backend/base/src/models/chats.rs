use loco_rs::prelude::*;

use super::_entities::chats;
pub type Chats = chats::Entity;

impl ActiveModelBehavior for chats::ActiveModel {
    // extend activemodel below (keep comment for generators)
}
