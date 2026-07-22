use std::sync::OnceLock;

use loco_rs::Result;

#[async_trait::async_trait]
pub trait AsrService: Send + Sync {
    async fn transcribe(&self, audio_url: &str, duration_sec: i32) -> Result<String>;
}

static ASR: OnceLock<Box<dyn AsrService + Send + Sync>> = OnceLock::new();

pub fn init_asr(svc: Box<dyn AsrService + Send + Sync>) {
    let _ = ASR.set(svc);
}

pub fn get_asr() -> Option<&'static (dyn AsrService + Send + Sync)> {
    ASR.get().map(|b| b.as_ref())
}

pub struct StubAsr;

#[async_trait::async_trait]
impl AsrService for StubAsr {
    async fn transcribe(&self, _audio_url: &str, _duration_sec: i32) -> Result<String> {
        Ok("[转文字功能待接入]".to_string())
    }
}
