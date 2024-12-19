pub mod chats;
pub mod cmvs;
pub mod feeds;
pub mod messages;

use loco_rs::Result;
use prost::Message;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

use common::{VecBool, common_error, pb_decode};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct MessageReaction {
    pub reactions: HashMap<i32, Vec<i64>>,
}

#[derive(Serialize, PartialEq, Deserialize, Clone, Message)]
pub struct MapItem {
    #[prost(uint32, tag = "1")]
    pub index: u32,
    #[prost(bool, tag = "2")]
    pub exists: bool,
}

#[derive(Serialize, Deserialize, Clone, Message)]
pub struct Cmv {
    #[prost(map = "int64, message", tag = "1")]
    pub members: HashMap<i64, MapItem>,
    #[prost(int64, tag = "2")]
    pub id: i64,
    #[prost(int32, tag = "3")]
    pub count: i32,
    #[prost(message, required, tag = "4")]
    pub cmv: VecBool,
}

impl Cmv {
    pub fn from_chat(chat: &chats::Model) -> Self {
        Self {
            id: chat.id,
            count: 0,
            members: HashMap::new(),
            cmv: VecBool::new(),
        }
    }

    pub fn new(id: i64, members: &[i64]) -> Self {
        let len = members.len();
        Self {
            id,
            count: len as i32,
            members: members
                .iter()
                .enumerate()
                .map(|(i, id)| {
                    (
                        *id,
                        MapItem {
                            index: i as u32,
                            exists: true,
                        },
                    )
                })
                .collect(),
            cmv: VecBool::with_ones(len as u64),
        }
    }
}
impl Cmv {
    pub fn from(value: &[u8]) -> Result<Self> {
        pb_decode::<Cmv>(value)
    }
    pub fn to(&self) -> Vec<u8> {
        self.encode_to_vec()
    }

    pub fn contains_key(&self, id: i64) -> bool {
        self.members.contains_key(&id)
    }

    // add new member
    pub fn add(&mut self, ids: &[i64]) -> Result<bool> {
        let mut new_user = Vec::new();
        let mut updated = false;
        for id in ids.iter() {
            match self.members.get_mut(id) {
                Some(item) => {
                    if !item.exists {
                        updated = true;
                        self.count += 1;
                        item.exists = true;
                        self.cmv.set(item.index as usize, true);
                    }
                }
                None => {
                    updated = true;
                    new_user.push(*id);
                    let count = self.members.len();
                    self.members.insert(
                        *id,
                        MapItem {
                            index: count as u32,
                            exists: true,
                        },
                    );
                    self.count += 1;
                    self.cmv.push(true);
                }
            }
        }
        Ok(updated)
    }

    // remove member
    pub fn remove(&mut self, ids: &[i64]) -> Result<bool> {
        let mut updated = false;
        for id in ids.iter() {
            match self.members.get_mut(id) {
                Some(item) => {
                    if item.exists {
                        item.exists = false;
                        updated = true;
                        self.cmv.set(item.index as usize, false);
                        self.count -= 1;
                    }
                }
                None => {}
            }
        }
        Ok(updated)
    }

    // use self to set cmv
    pub fn set(&self, cmv: &mut VecBool, ids: &[i64]) -> bool {
        let mut updated = false;
        for id in ids.iter() {
            if let Some(item) = self.members.get(id) {
                if item.exists {
                    updated = true;
                    cmv.set(item.index as usize, true);
                }
            }
        }

        updated
    }

    // use self to clear cmv
    pub fn clear(&self, cmv: &mut VecBool, ids: &[i64]) -> bool {
        let mut updated = false;
        for id in ids.iter() {
            if let Some(item) = self.members.get(id) {
                if item.exists {
                    updated = true;
                    cmv.set(item.index as usize, false);
                }
            }
        }

        updated
    }

    pub fn ids(&self) -> Vec<i64> {
        self.members
            .iter()
            .filter_map(|(id, item)| if item.exists { Some(*id) } else { None })
            .collect()
    }

    pub fn extract(&self, cmv: &VecBool) -> Vec<i64> {
        self.members
            .iter()
            .filter_map(|(id, item)| {
                if item.index < (cmv.len() as u32) && cmv.get(item.index as usize).unwrap_or(false)
                {
                    Some(*id)
                } else {
                    None
                }
            })
            .collect()
    }

    pub fn cmv(&self) -> VecBool {
        self.cmv.clone()
    }
}
