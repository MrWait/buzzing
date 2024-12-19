use std::sync::OnceLock;
use tracing::debug;

pub trait FfiCallback: Send + Sync {
    fn call(&self, data: Vec<u8>);
}

static FFI_INVOKE: OnceLock<Box<dyn FfiCallback>> = OnceLock::new();
static FFI_PUSH: OnceLock<Box<dyn FfiCallback>> = OnceLock::new();

pub fn reg_flutter_push(f: Box<dyn FfiCallback>) {
    FFI_PUSH.get_or_init(|| f);
}

pub fn reg_flutter_invoke(f: Box<dyn FfiCallback>) {
    FFI_INVOKE.get_or_init(|| f);
}

pub(crate) fn flutter_packet_response(data: Vec<u8>) {
    if let Some(ffi) = FFI_INVOKE.get() {
        // debug!("push respones to flutter: {:?}", data);
        let _ = ffi.call(data);
    } else {
        debug!("invoke  handler  not reg");
    }
}

pub(crate) fn flutter_packet_push(data: Vec<u8>) {
    if let Some(ffi) = FFI_PUSH.get() {
        // debug!("push packet to flutter: {:?}", data);
        let _ = ffi.call(data);
    } else {
        debug!("push handler not reg");
    }
}

pub fn init_sdk(param: &[u8]) -> i32 {
    crate::app::init_sdk(param, crate::app::FfiType::FfiFlutter)
}

pub fn invoke(param: &[u8]) -> i32 {
    crate::app::invoke(param);
    0
}
