use std::path::PathBuf;
use std::sync::OnceLock;
use tracing_appender::{non_blocking, non_blocking::WorkerGuard, rolling};
use tracing_subscriber::filter::LevelFilter;
use tracing_subscriber::layer::SubscriberExt;
use tracing_subscriber::util::SubscriberInitExt;
use tracing_subscriber::prelude::*;
use tracing_subscriber::{fmt, Registry};

mod ulog;

static LOG: OnceLock<WorkerGuard> = OnceLock::new();
const LOG_PREFIX: &str = "buzzing.sdk.log";

pub fn init_log(path: &str) {
    if path.is_empty() {
        return;
    }

    let file_appender = rolling::daily(path, LOG_PREFIX);
    let (non_blocking_appender, _guard) = non_blocking(file_appender);
    let _ = LOG.get_or_init(|| _guard);

    let file_layer = fmt::layer()
        .with_ansi(false)
        .with_writer(non_blocking_appender)
        .with_filter(LevelFilter::DEBUG);

    #[cfg(target_os = "android")]
    {
        if let Ok(layer) = tracing_android::layer("buzzing_sdk") {
            let _ = Registry::default()
                .with(file_layer)
                .with(layer.with_filter(LevelFilter::DEBUG))
                .try_init();
        }
    }

    #[cfg(not(target_os = "android"))]
    {
        let _ = Registry::default()
            .with(file_layer)
            .try_init();
    }

    log::set_max_level(log::LevelFilter::Debug);

    if let Ok(path) = path.parse::<PathBuf>() {
        let _ = reduce_log(&path, 7);
    }

    tracing::info!("init log");
}

fn get_files(path: &PathBuf) -> anyhow::Result<Vec<PathBuf>> {
    let mut files = std::fs::read_dir(path)?
        .map(|res| res.map(|e| e.path()))
        .collect::<Result<Vec<_>, std::io::Error>>()?;

    files.retain(|f| {
        f.file_name()
            .and_then(|name| name.to_str())
            .and_then(|s| Some(s.contains(LOG_PREFIX)))
            .unwrap_or(false)
    });
    files.sort();
    Ok(files)
}

fn reduce_log(path: &PathBuf, limit: usize) -> anyhow::Result<()> {
    let mut files = get_files(path)?;
    tracing::debug!("logs after filter: {:?}", files);

    if files.len() > limit {
        let c = files.len() - limit;
        let mut remove = Vec::new();
        files.drain(0..c).for_each(|f| {
            remove.push(f);
        });
        tracing::debug!("need remove log files: {:?}", remove);
        remove.iter().for_each(|f| {
            let _ = std::fs::remove_file(f);
        });
    }

    Ok(())
}
