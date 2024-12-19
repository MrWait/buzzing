#![feature(thread_id_value)]
use anyhow::Result;
use b64::FromBase64;
use rand::Rng;
use std::io::Read;

pub fn db_get_crypt_key(space: &str, uid: &str) -> String {
    let digest = md5::compute(format!("{}{}", space, uid));
    format!("{:x}", digest)
}

/*
pub fn http_decompress(input: &[u8], output: &mut Vec<u8>) -> Result<()> {
    let src = input.from_base64()?;
    let mut gz = flate2::read::GzDecoder::new(&src[..]);
    gz.read_to_end(output)?;
    Ok(())
}
*/

pub mod time {
    use std::time::{SystemTime, UNIX_EPOCH};
    pub fn current_ms() -> u128 {
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .and_then(|duration| Ok(duration.as_micros()))
            .unwrap_or(0)
    }

    pub fn current_s() -> u64 {
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .and_then(|duration| Ok(duration.as_secs()))
            .unwrap_or(0)
    }
}

pub mod lock {
    pub use parking_lot::{MappedMutexGuard, Mutex, MutexGuard, RwLock};
}

const ID_BASE: i64 = std::i64::MAX / 2;
pub fn id_gen() -> i64 {
    let id: i64 = rand::thread_rng().gen::<i64>() / 2 + ID_BASE;
    id
}

pub fn gen_i32() -> i32 {
    let id: i32 = rand::thread_rng().gen::<i32>();
    id
}

pub fn thread_id() -> u64 {
    std::thread::current().id().as_u64().into()
}
