use prost::Message;
use std::sync::atomic::{AtomicBool, AtomicI32, Ordering};
use std::sync::{Arc, OnceLock};
use tracing::{debug, info, instrument};

use app_account::AppAccount;
use app_calendar::AppCalendar;
use app_chat::AppChat;
use app_common::AppCommon;
use app_ffi::AppFfi;
use app_network::AppNetwork;
use app_todo::AppTodo;
use base_util::{gen_i32, thread_id};
use proto::idl::{command, sdk};
use service::{
    account::DefaultAccount, calendar::DefaultCalendar, chat::DefaultChat, common::DefaultCommon,
    ffi::DefaultFfi, network::DefaultNetwork, todo::DefaultTodo,
};
use service::{AppTrait, BizHub, InitRequest, LoginRequest, UnionClientConfig};
use service::{BizAccount, BizCalendar, BizChat, BizCommon, BizFfi, BizNetwork, BizTodo};

#[allow(dead_code)]
pub enum FfiType {
    FfiNode,
    FfiFlutter,
    FfiNative,
}

static FFI_TYPE: OnceLock<FfiType> = OnceLock::new();
static PUSH_SEQ: AtomicI32 = AtomicI32::new(0);
static INIT: AtomicBool = AtomicBool::new(false);

pub fn init_sdk(param: &[u8], tpy: FfiType) -> i32 {
    if INIT.load(Ordering::Relaxed) {
        debug!("sdk already inited");
        return 0;
    }
    INIT.store(true, Ordering::Relaxed);

    FFI_TYPE.get_or_init(move || tpy);
    base_runtime::init();

    let req = match sdk::InitRequest::decode(param) {
        Ok(req) => InitRequest {
            device_id: req.device_id,
            device_type: req.device_type,
            app_id: req.app_id,
            app_version: req.app_version,
            log_path: req.log_path,
            storage_path: req.storage_path,
            locale: req.locale,
            common_data_path: req.common_data_path,
        },
        Err(err) => {
            println!("parse init req err: {:?}", err);
            return -1;
        }
    };

    base_log::init_log(&req.log_path);
    //let _ = base_db::init();
    debug!("sdk info: {:?}", proto::get_build_info());
    debug!("init with {:?}", req);

    let account = Box::new(AppAccount::new());
    let chat = Box::new(AppChat::new());
    let common = Box::new(AppCommon::new());
    let ffi = Box::new(AppFfi::new(push_packet));
    let network = Box::new(AppNetwork::new());
    let calendar = Box::new(AppCalendar::new());
    let todo = Box::new(AppTodo::new());

    // let account = Box::new(DefaultAccount);
    // let chat = Box::new(DefaultChat);
    // let common = Box::new(DefaultCommon);
    // let ffi = Box::new(DefaultFfi);
    // let network = Box::new(DefaultNetwork);
    // let calendar = Box::new(DefaultCalendar);
    // let todo = Box::new(DefaultTodo);

    let app = BizHub {
        app_account: Arc::new(account.clone() as Box<dyn AppTrait>),
        app_chat: Arc::new(chat.clone() as Box<dyn AppTrait>),
        app_common: Arc::new(common.clone() as Box<dyn AppTrait>),
        app_ffi: Arc::new(ffi.clone() as Box<dyn AppTrait>),
        app_network: Arc::new(network.clone() as Box<dyn AppTrait>),
        app_calendar: Arc::new(calendar.clone() as Box<dyn AppTrait>),

        ffi_handlers: dashmap::DashMap::new(),
        net_handlers: dashmap::DashMap::new(),

        account: Arc::new(account.clone() as Box<dyn BizAccount>),
        calendar: Arc::new(calendar.clone() as Box<dyn BizCalendar>),
        chat: Arc::new(chat.clone() as Box<dyn BizChat>),
        common: Arc::new(common.clone() as Box<dyn BizCommon>),
        ffi: Arc::new(ffi.clone() as Box<dyn BizFfi>),
        network: Arc::new(network.clone() as Box<dyn BizNetwork>),
        todo: Arc::new(todo.clone() as Box<dyn BizTodo>),
    };

    BizHub::set(app);

    if let Ok(app) = BizHub::get() {
        let _ = app.account.init(&req);
        let _ = app.ffi.init(&req);
        let _ = app.network.init(&req);
        let _ = app.chat.init(&req);
        let _ = app.common.init(&req);
    }

    return 0;
}

pub(crate) fn uninit_sdk(_param: &[u8]) -> i32 {
    0
}

pub(crate) fn get_services() -> Vec<Arc<Box<dyn AppTrait>>> {
    BizHub::get()
        .and_then(|hub| Ok(hub.get_all()))
        .unwrap_or_default()
}

pub(crate) fn invoke(param: &[u8]) -> anyhow::Result<()> {
    let invoke = sdk::InvokeRequest::decode(param)?;
    invoke_impl(invoke.seq, invoke.command, invoke.payload)
}

pub(crate) fn invoke_impl(seq: i32, command: i32, payload: Vec<u8>) -> anyhow::Result<()> {
    let cmd = match command.try_into() {
        Ok(c) => c,
        Err(_err) => {
            info!("command not support: {}, {seq}", command);
            invoke_response(seq, -1, vec![]);
            return Ok(());
        }
    };
    let now = std::time::Instant::now();
    if cmd == command::Command::SdkWriteLog {
        let req = sdk::WriteClientLog::decode(payload.as_slice())?;
        debug!("[CLIET_LOG] {:?}", req);
        return Ok(());
    }
    debug!("invoke sdk with {command}, {seq}, len: {:?}", payload.len(),);

    match cmd {
        command::Command::UserLogin => {
            base_runtime::start();

            let req = sdk::SdkLoginUserRequest::decode(payload.as_slice())?;
            let client_config = serde_json::from_str::<UnionClientConfig>(&req.union_client_config)
                .unwrap_or_default();
            let req = LoginRequest {
                user_id: req.user_id,
                token: req.access_token,
                tenant_id: req.tenant_id,
                client_config,
            };
            // maybe has implicit dependens
            // Account -> Network -> XX
            info!("login user: {}, req: {:?}", req.user_id, req);
            for service in get_services() {
                let _ = service.login(&req);
            }
            invoke_response(seq, 200, vec![]);
        }
        command::Command::UserLogout => {
            debug!("user logout");
            for service in get_services() {
                let _ = service.logout();
            }
            base_runtime::stop();
            debug!("logout finish");
            invoke_response(seq, 200, vec![1, 2, 3]);
        }

        _ => {
            debug!("use ffi to invoke");
            let success = base_runtime::spawn(async move {
                let _ = handle_ffi_command(seq, now, command, payload).await;
            });
            if !success {
                debug!("user not logined");
                invoke_response(seq, -1, vec![]);
            }
        }
    }
    Ok(())
}

#[instrument(skip(data, now), fields(sid=gen_i32(), tid=thread_id()))]
async fn handle_ffi_command(
    seq: i32,
    now: std::time::Instant,
    command: i32,
    data: Vec<u8>,
) -> anyhow::Result<()> {
    let hub = BizHub::get()?;
    match hub.invoke_ffi_command(command, &data).await {
        Ok((code, res)) => {
            info!(
                "request handled, {seq}, cmd: {command}, code: {code}, {}, cost: {:?}",
                res.len(),
                now.elapsed().as_micros()
            );
            invoke_response(seq, code, res);
        }
        Err(err) => {
            info!(
                "request not handled: {seq}, cmd: {command}, cost: {:?}, err: {err:?}",
                now.elapsed().as_micros()
            );
            invoke_response(seq, -1, vec![]);
        }
    }
    Ok(())
}

pub(crate) fn invoke_response(seq: i32, status: i32, payload: Vec<u8>) {
    debug!("invoke response: seq: {}, code: {}, len: {}", seq, status, payload.len());
    let resp = sdk::InvokeResponse {
        seq,
        status,
        payload,
        ..Default::default()
    };

    match FFI_TYPE.get() {
        Some(FfiType::FfiFlutter) => {
            crate::ffi_flutter::flutter_packet_response(resp.encode_to_vec())
        }
        Some(FfiType::FfiNode) => crate::ffi_node::node_packet_response(resp.encode_to_vec()),
        Some(FfiType::FfiNative) => crate::ffi_native::invoke_response(seq, resp),
        _ => {
            debug!("no invoke handler  register");
        }
    }
}

pub(crate) fn push_packet(cmd: i32, payload: Vec<u8>) {
    let seq = PUSH_SEQ.fetch_add(1, Ordering::Relaxed);
    debug!("push packet to client, cmd: {cmd}, len: {}", payload.len());
    let resp = sdk::SdkPushPacket {
        command: cmd,
        user_id: 0,
        seq,
        payload,
    };
    // debug!("push packet to client, resp: {:?}", resp);
    match FFI_TYPE.get() {
        Some(FfiType::FfiFlutter) => crate::ffi_flutter::flutter_packet_push(resp.encode_to_vec()),
        Some(FfiType::FfiNode) => crate::ffi_node::node_packet_push(resp.encode_to_vec()),
        Some(FfiType::FfiNative) => crate::ffi_native::push_packet(resp),
        _ => {
            debug!("no invoke handler  register");
        }
    }
}

#[allow(dead_code)]
pub(crate) fn loop_push() {
    base_runtime::spawn(async {
        let mut count = 0;
        loop {
            count += 1;
            let data = vec![1, 2, 3];
            crate::ffi_node::node_packet_push(data);
            // crate::flutter_packet_push(&data);
            tokio::time::sleep(std::time::Duration::from_secs(1)).await;
            if count > 1 {
                break;
            }
        }
    });
}
