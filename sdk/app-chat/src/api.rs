use anyhow::{anyhow, Result};
use prost::Message;
use tracing::debug;

use proto::idl::{self, chat, command, feed, pipeline};
use service::network::request;

pub(crate) async fn common_request<T>(cmd: i32, data: Vec<u8>) -> Result<T>
where
    T: Message + Default,
{
    debug!("common request, cmd: {}, data len: {}", cmd, data.len());
    let resp = match request(cmd, data, None).await {
        Ok(resp) => resp,
        Err(err) => {
            debug!("common request error: {:?}", err);
            return Err(err);
        }
    };
    if resp.is_success() {
        debug!("common request ok");
        let ack = T::decode(resp.data.as_slice())?;
        return Ok(ack);
    } else {
        return Err(anyhow!("common request error for {cmd}"));
    }
}

pub(crate) async fn chat_create(req: &chat::CreateChatRequest) -> Result<chat::CreateChatResponse> {
    common_request(command::Command::ChatCreate as i32, req.encode_to_vec())
        .await
        .map_err(|_| anyhow!("chat create error"))
}

pub(crate) async fn feed_get_list(
    req: &feed::PullFeedListRequest,
) -> Result<feed::PullFeedListResponse> {
    common_request(command::Command::FeedGetList as i32, req.encode_to_vec())
        .await
        .map_err(|_| anyhow!("feet get list error"))
}

pub(crate) async fn pipe_pull_entity(
    req: &pipeline::PullEntityRequest,
) -> Result<pipeline::PullEntityResponse> {
    common_request(
        command::Command::PipelinePullEntity as i32,
        req.encode_to_vec(),
    )
    .await
    .map_err(|_| anyhow!("feet get list error"))
}

pub(crate) async fn message_send(
    req: &idl::message::SendMessageRequest,
) -> Result<idl::message::SendMessageResponse> {
    common_request(command::Command::MessageSend as i32, req.encode_to_vec())
        .await
        .map_err(|_| anyhow!("message send error"))
}

pub(crate) async fn message_get_by_pos(
    req: &idl::message::GetMessageByPosRequest,
) -> Result<idl::message::GetMessageByPosResponse> {
    common_request(
        command::Command::MessageGetByPos as i32,
        req.encode_to_vec(),
    )
    .await
    .map_err(|_| anyhow!("message get by pos error"))
}
