use anyhow::Result;
use prost::Message as _;

use crate::AppChat;
use proto::idl::{command::Command, error::ErrorCode, message};
use service::network::common_request;

impl AppChat {
    pub(crate) async fn favorite_add(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = message::FavoriteAddRequest::decode(params)?;
        if req.favorite.is_none() {
            return Ok((0, vec![]));
        }

        let ack: message::FavoriteAddResponse =
            common_request(Command::FavoriteAdd as i32, params.to_vec(), None).await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn favorite_remove(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let req = message::FavoriteRemoveRequest::decode(params)?;
        if req.id == 0 {
            return Ok((0, vec![]));
        }

        let ack: message::FavoriteRemoveResponse =
            common_request(Command::FavoriteRemove as i32, params.to_vec(), None).await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }

    pub(crate) async fn favorite_get_list(&self, params: &[u8]) -> Result<(i32, Vec<u8>)> {
        let ack: message::GetFavoriteListRequest =
            common_request(Command::FavoriteGetList as i32, params.to_vec(), None).await?;
        Ok((ErrorCode::Ok as i32, ack.encode_to_vec()))
    }
}
