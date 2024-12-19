use serde::{Deserialize, Serialize};

use proto::idl::entity::Account;

#[derive(Debug, Deserialize, Serialize)]
pub struct LoginResponse {
    pub account: Account,
}

impl LoginResponse {
    #[must_use]
    pub fn new(account: Account) -> Self {
        Self { account }
    }
}
