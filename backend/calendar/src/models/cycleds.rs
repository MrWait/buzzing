use loco_rs::{model::ModelResult, prelude::*};
use tracing::debug;

pub use base::models::_entities::cycleds::{ActiveModel, Column, Entity, Model};
use common::time::current_ms;
use common::{EntityStatus, EntityType, cost, id_gen, peer_pair};
use proto::idl::entity;

#[derive(Debug)]
pub struct CycledModel(pub Model);

impl CycledModel {}
