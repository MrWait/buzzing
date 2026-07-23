use std::sync::LazyLock;
use std::sync::Mutex;

static TRANSLATION_SERVICE: LazyLock<Mutex<Option<&'static (dyn TranslationService + Send + Sync)>>> =
    LazyLock::new(|| Mutex::new(None));

pub fn init_translation(svc: Box<dyn TranslationService + Send + Sync>) {
    let svc_ref: &'static mut (dyn TranslationService + Send + Sync) = Box::leak(svc);
    let mut guard = TRANSLATION_SERVICE.lock().unwrap();
    *guard = Some(svc_ref);
}

pub fn get_translation() -> Option<&'static (dyn TranslationService + Send + Sync)> {
    let guard = TRANSLATION_SERVICE.lock().unwrap();
    *guard
}

#[derive(Debug, Clone)]
pub struct TranslateResult {
    pub translated_text: String,
    pub source_lang: String,
}

#[derive(Debug, Clone)]
pub struct Language {
    pub code: String,
    pub name: String,
}

#[async_trait::async_trait]
pub trait TranslationService: Send + Sync {
    async fn translate(
        &self,
        text: &str,
        target: &str,
        source: Option<&str>,
    ) -> Result<TranslateResult, String>;
    fn supported_languages(&self) -> Vec<Language>;
}

/// Stub implementation that returns a placeholder message
pub struct StubTranslation;

#[async_trait::async_trait]
impl TranslationService for StubTranslation {
    async fn translate(
        &self,
        text: &str,
        target: &str,
        _source: Option<&str>,
    ) -> Result<TranslateResult, String> {
        Ok(TranslateResult {
            translated_text: format!("[翻译服务未配置] {text} (→{target})"),
            source_lang: "auto".to_string(),
        })
    }

    fn supported_languages(&self) -> Vec<Language> {
        vec![
            Language { code: "en".into(), name: "English".into() },
            Language { code: "zh".into(), name: "中文".into() },
            Language { code: "ja".into(), name: "日本語".into() },
        ]
    }
}
