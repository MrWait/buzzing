pub mod prelude {
    pub use crate::meta::MetaTable;
    pub use crate::DbConn;
    pub use rusqlite::*;
}
pub mod meta;

use anyhow::{anyhow, Result};
use std::path::PathBuf;
use std::sync::{OnceLock, Arc};
use tracing::debug;

use base_util::lock::{MappedMutexGuard, Mutex, MutexGuard};
use prelude::Connection;

#[derive(Clone)]
pub struct DbConn {
    inner: Arc<Mutex<Option<Connection>>>,
}
impl std::fmt::Debug for DbConn {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "DbConn")
    }
}

impl Default for DbConn {
    fn default() -> Self {
        Self {
            inner: Arc::new(Mutex::new(None)),
        }
    }
}

impl DbConn {
    pub fn new(conn: Connection) -> Self {
        Self {
            inner: Arc::new(Mutex::new(Some(conn))),
        }
    }

    pub fn set(&self, conn: Connection) {
        let mut inner = self.inner.lock();
        inner.replace(conn);
    }

    pub fn inner(&self) -> Result<MappedMutexGuard<'_, Connection>> {
        let lock = self.inner.lock();
        MutexGuard::try_map(lock, |conn: &mut Option<Connection>| conn.as_mut())
            .map_err(|_| anyhow::anyhow!("DB not init"))
    }

    pub fn open(path: &PathBuf, name: &str, key: Option<&str>) -> prelude::Result<Connection> {
        let conn = match Self::open_impl(path, name, key) {
            Ok(conn) => conn,
            Err(err) => {
                debug!("open db error: {err:?}, try remove: {:?}, {:?}", path, name);
                Self::remove(path, name)?;
                Self::open_impl(path, name, key)?
            }
        };
        Ok(conn)
    }

    fn open_impl(path: &PathBuf, name: &str, key: Option<&str>) -> prelude::Result<Connection> {
        let conn = Connection::open(&path.join(name))?;
        if let Some(key) = key {
            conn.execute_batch(&format!("PRAGMA key='{}'", key))?;
        }
        conn.execute_batch("PRAGMA synchronous=NORMAL")?;
        conn.execute_batch("PRAGMA journal_mode=WAL")?;
        Ok(conn)
    }

    fn remove(path: &PathBuf, name: &str) -> prelude::Result<()> {
        let _ = std::fs::remove_file(path.join(name));
        let _ = std::fs::remove_file(path.join(name.to_owned() + "-shm"));
        let _ = std::fs::remove_file(path.join(name.to_owned() + "-wal"));
        Ok(())
    }

    pub fn reset(&self) {
        let mut inner = self.inner.lock();
        let _ = inner.take();
    }
}
unsafe impl Sync for DbConn {}
unsafe impl Send for DbConn {}

const PLACE_HOLHDER: &str =
    "  ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9,?10,?11,?12,?13,?14,?15,?16,?17,?18,?19,?20,?21,?22,?23,?24,?25,?26,?27,?28,?29,?30,?31,?32,?33,?34,?35,?36,?37,?38,?39,?40,?41,?42,?43,?44,?45,?46,?47,?48,?49,?50,?51,?52,?53,?54,?55,?56,?57,?58,?59,?60,?61,?62,?63,?64,?65,?66,?67,?68,?69,?70,?71,?72,?73,?74,?75,?76,?77,?78,?79,?80,?81,?82,?83,?84,?85,?86,?87,?88,?89,?90,?91,?92,?93,?94,?95,?96,?97,?98,?99,?100";

// only gen within 99
pub fn placeholder(count: usize) -> &'static str {
    assert!(count < 100);
    &PLACE_HOLHDER[..(count * 4)]
}

static DICT_DIR: OnceLock<PathBuf> = OnceLock::new();

pub fn get_dict_dir() -> Option<&'static PathBuf> {
    DICT_DIR.get()
}

// call before use db
pub fn init() -> Result<()> {
    //libsimple::enable_auto_extension()?;
    let dir = tempfile::tempdir()?;
    //libsimple::release_dict(&dir)?;
    let _ = DICT_DIR.get_or_init(|| dir.into_path());
    Ok(())
}

pub fn init_fts(conn: &Connection) -> Result<()> {
    let dir = DICT_DIR.get().ok_or_else(|| anyhow!("dict not set"))?;
    //libsimple::set_dict(conn, dir).map_err(|_err| anyhow!("init fts error"))
    Ok(())
}

pub struct Cost<'a> {
    name: &'a str,
    now: std::time::Instant,
}
impl<'a> Cost<'a> {
    pub fn new(name: &'a str) -> Cost<'a> {
        Cost {
            name,
            now: std::time::Instant::now(),
        }
    }
}
impl Drop for Cost<'_> {
    fn drop(&mut self) {
        tracing::debug!(
            "db_cost, name: {}  {}",
            self.name,
            self.now.elapsed().as_micros()
        );
    }
}

#[macro_export]
macro_rules! cost {
    ($e:expr) => {
        let __cost = $crate::Cost::new($e);
        scopeguard::defer! { drop(__cost); }
    };
}

pub struct Pagerize<'a, T> {
    origin: &'a [T],
    index: usize,
    page: usize,
}
impl<'a, T> Iterator for Pagerize<'a, T> {
    type Item = &'a [T];

    fn next(&mut self) -> Option<Self::Item> {
        let l = self.origin.len();
        let index = self.index;
        self.index += self.page;
        if (index + self.page) < l {
            return Some(&self.origin[index..(index + self.page)]);
        } else if index < l {
            return Some(&self.origin[index..]);
        } else {
            return None;
        }
    }
}
impl<'a, T> Pagerize<'a, T> {
    pub fn new(origin: &'a [T], page: usize) -> Self {
        Self {
            origin,
            index: 0,
            page,
        }
    }
}
