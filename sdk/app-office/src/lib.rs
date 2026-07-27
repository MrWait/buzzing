use anyhow::Result;
use async_trait::async_trait;
use reqwest::header::HeaderMap;
use serde::{Deserialize, Serialize};

use service::{AppTrait, BizOffice, BizHub, Event, InitRequest, LoginRequest};

#[derive(Debug, Clone)]
pub struct AppOffice {}
impl AppOffice {
    pub fn new() -> Self {
        AppOffice {}
    }

    fn base_url() -> Result<String> {
        let hub = BizHub::get()?;
        let user_info = hub.account.get_user_info();
        let api = hub.network.api();
        let base = api.trim_end_matches("/api/v1").trim_end_matches('/');
        Ok(format!("{}/api/office", base))
    }

    fn headers() -> Result<HeaderMap> {
        let hub = BizHub::get()?;
        let user_info = hub.account.get_user_info();
        let mut headers = HeaderMap::new();
        headers.insert(
            "Authorization",
            format!("Bearer {}", user_info.token).parse()?,
        );
        headers.insert("Content-Type", "application/json".parse()?);
        Ok(headers)
    }

    pub async fn list_docs(&self, wiki_id: i64) -> Result<Vec<DocResponse>> {
        let url = format!("{}/docs", Self::base_url()?);
        let query = vec![("wiki_id", wiki_id.to_string())];
        let client = reqwest::Client::new();
        let resp = client
            .get(&url)
            .headers(Self::headers()?)
            .query(&query)
            .send()
            .await?
            .error_for_status()?
            .text()
            .await?;
        Ok(serde_json::from_str(&resp)?)
    }

    pub async fn create_doc(&self, wiki_id: i64, title: &str) -> Result<DocResponse> {
        let url = format!("{}/docs", Self::base_url()?);
        let body = serde_json::json!({ "wiki_id": wiki_id.to_string(), "title": title });
        let client = reqwest::Client::new();
        let resp = client
            .post(&url)
            .headers(Self::headers()?)
            .json(&body)
            .send()
            .await?
            .error_for_status()?
            .text()
            .await?;
        Ok(serde_json::from_str(&resp)?)
    }

    pub async fn get_doc(&self, id: i64) -> Result<DocResponse> {
        let url = format!("{}/docs/{}", Self::base_url()?, id);
        let client = reqwest::Client::new();
        let resp = client
            .get(&url)
            .headers(Self::headers()?)
            .send()
            .await?
            .error_for_status()?
            .text()
            .await?;
        Ok(serde_json::from_str(&resp)?)
    }

    pub async fn update_doc(&self, id: i64, title: Option<&str>) -> Result<DocResponse> {
        let url = format!("{}/docs/{}", Self::base_url()?, id);
        let mut body = serde_json::Map::new();
        if let Some(t) = title {
            body.insert("title".into(), serde_json::Value::String(t.into()));
        }
        let client = reqwest::Client::new();
        let resp = client
            .patch(&url)
            .headers(Self::headers()?)
            .json(&body)
            .send()
            .await?
            .error_for_status()?
            .text()
            .await?;
        Ok(serde_json::from_str(&resp)?)
    }

    pub async fn delete_doc(&self, id: i64) -> Result<()> {
        let url = format!("{}/docs/{}", Self::base_url()?, id);
        let client = reqwest::Client::new();
        client
            .delete(&url)
            .headers(Self::headers()?)
            .send()
            .await?
            .error_for_status()?;
        Ok(())
    }

    pub async fn get_edit_url(&self, id: i64) -> Result<EditUrlResponse> {
        let url = format!("{}/docs/{}/edit-url", Self::base_url()?, id);
        let client = reqwest::Client::new();
        let resp = client
            .get(&url)
            .headers(Self::headers()?)
            .send()
            .await?
            .error_for_status()?
            .text()
            .await?;
        Ok(serde_json::from_str(&resp)?)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocResponse {
    pub id: String,
    pub wiki_id: String,
    pub title: String,
    pub doc_type: i32,
    pub version: i64,
    pub created_at: String,
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EditUrlResponse {
    pub edit_url: String,
    pub title: String,
}

#[async_trait]
impl AppTrait for AppOffice {
    fn init(&self, _req: &InitRequest) -> Result<()> {
        Ok(())
    }
    fn uninit(&self) -> Result<()> {
        Ok(())
    }

    fn login(&self, _req: &LoginRequest) -> Result<()> {
        Ok(())
    }
    fn logout(&self) -> Result<()> {
        Ok(())
    }

    fn ffi_commands(&self) -> Vec<i32> {
        vec![]
    }

    fn net_commands(&self) -> Vec<i32> {
        vec![]
    }

    async fn on_ffi_command(&self, _command: i32, _params: &[u8]) -> Result<(i32, Vec<u8>)> {
        Err(anyhow::anyhow!("not handled"))
    }
    async fn on_net_command(&self, _source: i32, _command: i32, _params: &[u8]) -> Result<()> {
        Err(anyhow::anyhow!("not handled"))
    }
    fn on_event(&self, _event: Event, _params: &[u8]) {}
}

impl BizOffice for AppOffice {}
