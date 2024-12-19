use neon::types::buffer::TypedArray;
use neon::{handle::Root, prelude::*};
use prost::Message;
use std::sync::{LazyLock, RwLock};

use proto::idl::sdk;

static HANDLER_PUSH: LazyLock<RwLock<Option<Root<JsFunction>>>> =
    LazyLock::new(|| RwLock::new(None));
static HANDLER_RESPONSE: LazyLock<RwLock<Option<Root<JsFunction>>>> =
    LazyLock::new(|| RwLock::new(None));
static NODE_CHANNEL: LazyLock<RwLock<Option<Channel>>> = LazyLock::new(|| RwLock::new(None));

pub fn node_packet_push(data: Vec<u8>) {
    let mut packet = sdk::SdkPushPacket::default();
    packet.seq = 1;
    packet.command = 100;
    packet.payload = data;
    let channel = NODE_CHANNEL.read().unwrap();
    if channel.is_none() {
        return;
    }

    channel.as_ref().unwrap().send(move |mut cx| {
        let mut push_handler = HANDLER_PUSH.write().unwrap();
        let push_handler = push_handler.as_mut().expect("").clone(&mut cx);
        let push_handler = push_handler.to_inner(&mut cx);
        let data = packet.encode_to_vec();
        let this = cx.undefined();
        let args = vec![JsBuffer::from_slice(&mut cx, &data)?.upcast()];
        push_handler.call(&mut cx, this, args)?;
        Ok(())
    });
}

pub(crate) fn node_packet_response(data: Vec<u8>) {
    let channel = NODE_CHANNEL.read().unwrap();
    if channel.is_none() {
        return;
    }
    channel.as_ref().unwrap().send(move |mut cx| {
        let mut response_handler = HANDLER_RESPONSE.write().unwrap();
        let response_handler = response_handler.as_mut().expect("").clone(&mut cx);
        let response_handler = response_handler.to_inner(&mut cx);
        // debug!("response: {seq} {code} {data:?} {push:?}");
        let this = cx.undefined();
        let args = vec![JsBuffer::from_slice(&mut cx, &data)?.upcast()];
        response_handler.call(&mut cx, this, args)?;
        Ok(())
    });
}

fn buzzing_init(mut cx: FunctionContext) -> JsResult<JsUndefined> {
    let array: Handle<JsUint8Array> = cx.argument(0)?;
    let payload = array.as_slice(&mut cx);
    crate::app::init_sdk(payload, crate::app::FfiType::FfiNode);
    Ok(cx.undefined())
}

fn buzzing_uninit(mut cx: FunctionContext) -> JsResult<JsUndefined> {
    let array: Handle<JsUint8Array> = cx.argument(0)?;
    let payload = array.as_slice(&mut cx);
    crate::app::uninit_sdk(payload);
    Ok(cx.undefined())
}

fn buzzing_invoke(mut cx: FunctionContext) -> JsResult<JsNumber> {
    let array: Handle<JsUint8Array> = cx.argument(0)?;
    let payload = array.as_slice(&mut cx);

    let _ = crate::app::invoke(payload);

    Ok(cx.number(0))
}

fn buzzing_reg_handler(mut cx: FunctionContext) -> JsResult<JsUndefined> {
    let invoke_handler = cx.argument::<JsFunction>(0)?.root(&mut cx);
    let push_handler = cx.argument::<JsFunction>(1)?.root(&mut cx);
    let channel = cx.channel();

    let mut push = HANDLER_PUSH.write().unwrap();
    push.replace(push_handler);
    let mut response = HANDLER_RESPONSE.write().unwrap();
    response.replace(invoke_handler);
    let mut ch = NODE_CHANNEL.write().unwrap();
    ch.replace(channel);

    // crate::app::loop_push();

    Ok(cx.undefined())
}

#[neon::main]
fn node_entry(mut cx: ModuleContext) -> NeonResult<()> {
    cx.export_function("buzzing_init", buzzing_init)?;
    cx.export_function("buzzing_uninit", buzzing_uninit)?;
    cx.export_function("buzzing_invoke", buzzing_invoke)?;
    cx.export_function("buzzing_reg_handler", buzzing_reg_handler)?;
    Ok(())
}
