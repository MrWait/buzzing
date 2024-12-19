use crate::prelude::*;

#[allow(dead_code)]
#[derive(Deserialize, Debug, Default, Clone)]
pub struct ChatConfig {
    pub base: i64,
    pub count: i32,
    pub size: i32,
    pub output: String,
    pub p2p: bool,
}

#[allow(dead_code)]
#[derive(Deserialize, Debug, Default, Clone)]
pub struct MessageConfig {
    pub count: i32,
    pub peer: i32,
    pub duration: i32,
    pub interval: i32,
    pub conv: String,
    pub p2p: bool,
}

#[allow(dead_code)]
#[derive(Deserialize, Debug, Default)]
pub struct Config {
    pub target: String,
    pub scene: String,
    pub host: String,
    pub token: String,
    pub tenant: i64,
    pub device: String,
    pub appversion: String,
    pub chat: HashMap<String, ChatConfig>,
    pub message: HashMap<String, MessageConfig>,
    pub database: String,
}

pub(crate) fn load_config(path: &str) -> Result<Config> {
    let src = std::fs::read_to_string(path)?;
    let config: Config = toml::from_str(&src)?;
    Ok(config)
}

#[allow(dead_code)]
pub enum Task {
    TaskChatCreate(ChatConfig, entity::Packet),
    TaskMessageSend(MessageConfig, entity::Packet),
    TaskSlave,
}
#[allow(dead_code)]
impl Task {
    pub fn interval(&self) -> i32 {
        match self {
            Task::TaskMessageSend(config, _) => config.interval,
            _ => 500,
        }
    }

    pub fn repeat(&self) -> i32 {
        match self {
            Task::TaskChatCreate(_config, _) => 1,
            Task::TaskMessageSend(config, _) => config.duration / config.interval,
            _ => 1,
        }
    }
    pub fn send(&self, tx: &UnboundedSender<UserCommand>) -> bool {
        let mut pkt = match self {
            Task::TaskChatCreate(_, packet) => packet.clone(),
            Task::TaskMessageSend(_, packet) => packet.clone(),
            Task::TaskSlave => return false,
        };
        pkt.rid = crate::id_gen();
        let _ = tx.send(UserCommand::AsyncPacket(pkt));
        true
    }
}

#[allow(dead_code)]
pub enum Event {
    Start,
    Logined,
    Connection(i64, bool),
    SendPacket,
    RecvPacket,
    ActionStart,
    ActionAck(i32, i64, entity::Packet),
}

#[allow(dead_code)]
pub enum UserCommand {
    AsyncPacket(entity::Packet),
    Heartbeat,
    Packet(entity::Packet),
}

#[allow(dead_code)]
pub struct UserContext {
    pub event_ch: UnboundedSender<Event>,
    pub user_id: i64,
    pub tenant_id: i64,
    pub account_id: i64,
    pub token: String,
    pub task: Task,
    pub host: String,
    pub device: String,
    pub appversion: String,
}
