use serde::{Deserialize, Serialize};

use proto::idl::entity::{Department, User};

#[derive(Debug, Deserialize, Serialize)]
pub struct ListDeptResponse {
    pub id: i64,
    pub dept: Department,
    pub users: Vec<User>,
    pub sub_depts: Vec<Department>,
}

impl ListDeptResponse {
    #[must_use]
    pub fn new(id: i64, dept: Department, users: Vec<User>, sub_depts: Vec<Department>) -> Self {
        Self {
            id,
            dept,
            users,
            sub_depts,
        }
    }
}
