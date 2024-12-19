use loco_rs::{app::AppContext, Error, Result};
pub use prost::Enumeration;
pub use proto::idl::entity::EntityType;
use redis::{aio::MultiplexedConnection, Client};
use std::sync::OnceLock;

static CACHE: OnceLock<MultiplexedConnection> = OnceLock::new();
static CLIENT: OnceLock<Client> = OnceLock::new();

pub async fn cache_get(ctx: &AppContext) -> Result<MultiplexedConnection> {
    // TODO: 可能有多个线程同时触发，需要进行处理
    let cache = CACHE.get();
    if cache.is_none() {
        if CLIENT.get().is_none() {
            let uri =
                if let Some(loco_rs::config::QueueConfig::Redis(ref config)) = &ctx.config.queue {
                    config.uri.clone()
                } else {
                    return Err(Error::Message("no cache config".to_string()));
                };
            let client = redis::Client::open(&*uri)
                .map_err(|_| Error::Message("Open redis error".to_string()))?;
            CLIENT.get_or_init(move || client);
        }
        let client = CLIENT
            .get()
            .ok_or(Error::Message("Open redis error".to_string()))?;
        let cache = client
            .get_multiplexed_async_connection()
            .await
            .map_err(|_| Error::Message("Open redis error".to_string()))?;
        CACHE.get_or_init(|| cache.clone());
        return Ok(cache);
    }

    cache
        .ok_or(Error::Message("Open redis error".to_string()))
        .cloned()
}
