use crate::frb_generated::StreamSink;

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet2(name: String) -> String {
    format!("Go, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}


#[allow(unexpected_cfgs)]
#[flutter_rust_bridge::frb(sync)]
pub fn buzzing_init(param: Vec<u8>) -> i32 {
    // send request to ffi task processor
    // post to private runtime
    // get data by channel
    crate::init_sdk(&param)
}

#[allow(unused_must_use)]
#[flutter_rust_bridge::frb(sync)]
pub fn buzzing_invoke(param: Vec<u8>) -> i32 {
    crate::invoke(&param);
    0
}

#[allow(unexpected_cfgs)]
#[flutter_rust_bridge::frb(sync)]
pub fn buzzing_reg_push_handler(sink: StreamSink<Vec<u8>>) {
    crate::reg_flutter_push(sink);
}

#[flutter_rust_bridge::frb(sync)]
pub fn buzzing_reg_invoke_handler(sink: StreamSink<Vec<u8>>) {
    crate::reg_flutter_invoke(sink);
}
