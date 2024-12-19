use loco_rs::prelude::*;

use super::_entities::feeds;
pub type Feeds = feeds::Entity;

impl ActiveModelBehavior for feeds::ActiveModel {
    // extend activemodel below (keep comment for generators)
}
