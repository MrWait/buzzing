use anyhow::Result;
use prost::Message;
use reqwest::header::HeaderMap;
use std::collections::HashMap;
use std::sync::LazyLock;
use tracing::debug;

use base_util::lock::RwLock;
use proto::idl;
use service::network::{RequestOption, Response};
use service::{BizHub, UnionClientConfig};

static CLIENT_GLOBAL: RwLock<Option<reqwest::Client>> = RwLock::new(None);
static CLIENT_USER: RwLock<Option<reqwest::Client>> = RwLock::new(None);

pub fn get_common_header(logined: bool) -> Result<HeaderMap> {
    let mut header = HeaderMap::new();

    let acc = BizHub::get()?.account.clone();
    let device_info = acc.get_device_info();

    header.insert("x-buzzing-deviceid", device_info.device_id.clone().parse()?);
    header.insert(
        "x-buzzing-appversion",
        device_info.app_version.clone().parse()?,
    );
    header.insert("x-buzzing-appid", device_info.app_id.clone().parse()?);
    header.insert("x-buzzing-devicetype", device_info.device_type.into());

    if logined {
        let user_info = acc.get_user_info();
        header.insert(
            "Authorization",
            format!("Bearer {}", user_info.token).parse()?,
        );
    }

    Ok(header)
}

pub fn init_global_client() -> Result<()> {
    let headers = get_common_header(false)?;
    let client = reqwest::Client::builder()
        .default_headers(headers)
        .build()?;
    {
        let mut c = CLIENT_GLOBAL.write();
        *c = Some(client);
    }
    Ok(())
}

pub fn init_user_client(config: &UnionClientConfig) -> Result<()> {
    let headers = get_common_header(true)?;
    let client = reqwest::Client::builder()
        .default_headers(headers)
        .build()?;
    {
        let mut c = CLIENT_USER.write();
        *c = Some(client);
    }
    Ok(())
}

pub fn uninit_user_client() -> Result<()> {
    CLIENT_USER.write().take();
    Ok(())
}

pub async fn post(
    global: bool,
    path: &str,
    body: String,
    header: HashMap<String, String>,
) -> Result<String> {
    let client = if global {
        CLIENT_GLOBAL.read().clone()
    } else {
        CLIENT_USER.read().clone()
    };
    let api = BizHub::get()?.network.api();

    let client = client.ok_or(anyhow::anyhow!("Client not init"))?;
    let mut hdrs = header;
    hdrs.insert("content-type".to_owned(), "application/json".to_owned());

    debug!(
        "send post request, path: {}, body len: {}",
        path,
        body.len()
    );
    let ret = client
        .post(api)
        .headers((&hdrs).try_into()?)
        .body(body)
        .send()
        .await?
        .text()
        .await
        .map_err(|e| anyhow::Error::from(e));
    ret
}

pub async fn get(
    global: bool,
    path: &str,
    query: HashMap<String, String>,
    header: HashMap<String, String>,
) -> Result<String> {
    let client = if global {
        CLIENT_GLOBAL.read().clone()
    } else {
        CLIENT_USER.read().clone()
    };
    let api = BizHub::get()?.network.api();

    let hdrs = header;
    let client = client.ok_or(anyhow::anyhow!("Client not init"))?;
    debug!("send get request, path: {}, query: {:?}", path, query);
    let ret = client
        .get(api)
        .headers((&hdrs).try_into()?)
        .query(&query)
        .send()
        .await?
        .text()
        .await
        .map_err(|e| anyhow::Error::from(e));
    ret
}

pub async fn request(
    cmd: i32,
    rid: i64,
    body: Vec<u8>,
    _option: Option<RequestOption>,
) -> Result<Response> {
    let client = { CLIENT_USER.read().clone() };
    let client = client.ok_or(anyhow::anyhow!("Client not init"))?;
    debug!("send request, body len: {}", body.len());

    let api = BizHub::get()?.network.api();
    let data = reqwest::multipart::Part::bytes(body).file_name("data");

    let form = reqwest::multipart::Form::new().part("data", data);
    let mut header = HeaderMap::new();
    header.insert("cmd", cmd.to_string().parse()?);
    header.insert("rid", rid.to_string().parse()?);

    let ret = client
        .post(api)
        .headers(header)
        .multipart(form)
        .send()
        .await?
        .bytes()
        .await
        .map_err(|e| anyhow::Error::from(e))?;
    let pkt = idl::entity::Packet::decode(ret)?;
    Ok(Response {
        code: pkt.code,
        data: pkt.payload,
        rid: pkt.rid,
    })
}
