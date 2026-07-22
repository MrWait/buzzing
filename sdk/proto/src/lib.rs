use std::collections::{HashMap, HashSet};

shadow_rs::shadow!(build);

pub mod idl {
    pub mod chat {
        include!("idl/chat.rs");
    }
    pub mod command {
        include!("idl/command.rs");
    }
    pub mod dept {
        include!("idl/dept.rs");
    }
    pub mod entity {
        include!("idl/entity.rs");
    }
    pub mod error {
        include!("idl/error.rs");
    }
    pub mod feed {
        include!("idl/feed.rs");
    }
    pub mod message {
        include!("idl/message.rs");
    }
    pub mod pipeline {
        include!("idl/pipeline.rs");
    }
    pub mod sdk {
        include!("idl/sdk.rs");
    }
    pub mod user {
        include!("idl/user.rs");
    }
    pub mod setting {
        include!("idl/setting.rs");
    }
    pub mod calendar {
        include!("idl/calendar.rs");
    }
    pub mod meeting {
        include!("idl/meeting.rs");
    }
    pub mod mute {
        include!("idl/mute.rs");
    }
    pub mod invite {
        include!("idl/invite.rs");
    }
    pub mod join_request {
        include!("idl/join_request.rs");
    }
    pub mod pin {
        include!("idl/pin.rs");
    }
    pub mod thread {
        include!("idl/thread.rs");
    }
    pub mod presence {
        include!("idl/presence.rs");
    }
    pub mod typing {
        include!("idl/typing.rs");
    }
    pub mod search {
        include!("idl/search.rs");
    }
    pub mod timer {
        include!("idl/timer.rs");
    }
    pub mod translate {
        include!("idl/translate.rs");
    pub mod openapp {
        include!("idl/openapp.rs");
    }
}

pub fn get_build_info() -> HashMap<&'static str, &'static str> {
    let mut infos = HashMap::new();

    infos.insert("branch", build::BRANCH);
    infos.insert("commit", build::COMMIT_HASH);
    infos.insert("date", build::COMMIT_DATE);
    infos.insert("build_os", build::BUILD_OS);
    infos.insert("rust_version", build::RUST_VERSION);
    infos.insert("build", build::BUILD_TIME);

    infos
}

#[derive(Debug, Default, Clone)]
pub struct FeedDeps {
    pub chat: bool,
    pub message: bool,
}
#[derive(Debug, Default, Clone)]
pub struct ChatDeps {
    pub member: bool,
}

#[derive(Debug, Default, Clone)]
pub struct EntityIds {
    pub user_ids: HashSet<i64>,
    pub feed_ids: HashSet<i64>,
    pub message_ids: HashSet<i64>,
    pub chat_ids: HashSet<i64>,
    pub read_state_ids: HashSet<i64>,
    pub favorite_ids: HashSet<i64>,
    pub feed_deps: FeedDeps,
    pub chat_deps: ChatDeps,
    pub notify_type: idl::entity::EntityType,
}

impl EntityIds {
    pub fn fill_vec(&self) -> Vec<idl::entity::EntityId> {
        use idl::entity::{EntityId, EntityType::*};
        fn fill<'a, I: IntoIterator<Item = &'a i64>>(dst: &mut Vec<EntityId>, iter: I, t: i32) {
            dst.extend(iter.into_iter().map(|id| EntityId { id: *id, r#type: t }));
        }
        let mut ids = Vec::new();
        fill(&mut ids, self.user_ids.iter(), User as i32);
        fill(&mut ids, self.feed_ids.iter(), Feed as i32);
        fill(&mut ids, self.chat_ids.iter(), Chat as i32);
        fill(&mut ids, self.message_ids.iter(), Message as i32);
        fill(&mut ids, self.read_state_ids.iter(), Readstate as i32);
        ids
    }
}

#[derive(Debug, Default)]
pub struct EntityChanged {
    pub entity_update: HashMap<i32, Vec<(i64, i64)>>,
    pub entity_delete: HashMap<i32, Vec<i64>>,
    pub entity_create: HashMap<i32, Vec<i64>>,
}
impl EntityChanged {
    #[allow(deprecated)]
    pub fn from_idl(&mut self, ids: &[idl::entity::EntityChange]) {
        use idl::entity::Operate;
        for id in ids {
            let op = Operate::from_i32(id.operate).unwrap_or(Operate::None);
            match op {
                Operate::Delete => self
                    .entity_delete
                    .entry(id.r#type)
                    .or_insert(Vec::new())
                    .push(id.id),
                Operate::Update => self
                    .entity_update
                    .entry(id.r#type)
                    .or_insert(Vec::new())
                    .push((id.id, id.version)),
                Operate::Create => self
                    .entity_create
                    .entry(id.r#type)
                    .or_insert(Vec::new())
                    .push(id.id),
                _ => {}
            }
        }
    }
}
