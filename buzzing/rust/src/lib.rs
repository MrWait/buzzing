pub mod api;
mod frb_generated;

use buzzing::ffi_flutter::FfiCallback;
use std::sync::OnceLock;
use tracing::debug;

use crate::frb_generated::StreamSink;

static FLUTTER_SINK_INVOKE: OnceLock<StreamSink<Vec<u8>>> = OnceLock::new();
static FLUTTER_SINK_PUSH: OnceLock<StreamSink<Vec<u8>>> = OnceLock::new();

struct CallbackInvoke;
impl FfiCallback for CallbackInvoke {
    fn call(&self, data: Vec<u8>) {
        if let Some(sink) = FLUTTER_SINK_INVOKE.get() {
            // debug!("push respones to flutter: {:?}", data);
            let _ = sink.add(data);
        } else {
            debug!("invoke  handler  not reg");
        }
    }
}
struct CallbackPush;
impl FfiCallback for CallbackPush {
    fn call(&self, data: Vec<u8>) {
        if let Some(sink) = FLUTTER_SINK_PUSH.get() {
            // debug!("push packet to flutter: {:?}", data);
            let _ = sink.add(data);
        } else {
            debug!("push handler not reg");
        }
    }
}

pub(crate) fn reg_flutter_push(sink: StreamSink<Vec<u8>>) {
    FLUTTER_SINK_PUSH.get_or_init(move || sink);
    buzzing::ffi_flutter::reg_flutter_push(Box::new(CallbackPush));
}

pub(crate) fn reg_flutter_invoke(sink: StreamSink<Vec<u8>>) {
    FLUTTER_SINK_INVOKE.get_or_init(move || sink);
    buzzing::ffi_flutter::reg_flutter_invoke(Box::new(CallbackInvoke));
}

pub fn init_sdk(param: &[u8]) -> i32 {
    buzzing::ffi_flutter::init_sdk(param)
}

pub fn invoke(param: &[u8]) -> i32 {
    buzzing::ffi_flutter::invoke(param)
}
