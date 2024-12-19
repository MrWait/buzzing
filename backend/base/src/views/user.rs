use serde::{Deserialize, Serialize};

use crate::models::_entities::users;

#[derive(Debug, Deserialize, Serialize)]
pub struct CurrentResponse {
    pub id: String,
    pub name: String,
}

impl CurrentResponse {
    #[must_use]
    pub fn new(user: &users::Model) -> Self {
        Self {
            id: user.id.to_string(),
            name: user.name.to_string(),
        }
    }
}
