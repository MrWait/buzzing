use anyhow::Result;
use once_cell::sync::Lazy;
use std::future::Future;
use std::sync::Arc;
use tokio::runtime;
use tokio_util::sync::CancellationToken;
use tracing::debug;

//use parking_lot::{MappedMutexGuard, Mutex, MutexGuard, RwLock};
use base_util::lock::RwLock;

static RT: Lazy<Arc<runtime::Runtime>> = Lazy::new(|| {
    let rt = runtime::Runtime::new().expect("create tokio runtime error");
    Arc::new(rt)
});

static CT: RwLock<Option<CancellationToken>> = RwLock::new(None);

fn init_runtime() -> Result<()> {
    debug!("init runtime");
    RT.spawn(async {
        debug!("run in tokio");
    });
    Ok(())
}

pub fn init() {
    let _ = init_runtime();
}

pub fn start() {
    let mut ct = CT.write();
    *ct = Some(CancellationToken::new());
}

// call while switch user
pub fn stop() {
    let mut ct = CT.write();
    let token = ct.take();
    token.and_then(|c| Some(c.cancel()));
}

// spawn task run in user context
// will be cancel when user logout
pub fn spawn(f: impl Future<Output = ()> + Send + 'static) -> bool {
    let ct = {
        let ct = CT.read();
        if let Some(ct) = ct.as_ref() {
            ct.clone()
        } else {
            return false;
        }
    };
    RT.spawn(async move {
        tokio::select! {
            _ = ct.cancelled()=>  {}
            _ = f => {}
        }
    });
    true
}

// spawn task run in global context
// take care of user switch
pub fn spawn_global(f: impl Future<Output = ()> + Send + 'static) {
    RT.spawn(f);
}
