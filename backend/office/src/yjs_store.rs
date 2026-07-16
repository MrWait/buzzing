use loco_rs::prelude::*;
use yrs::{Doc, ReadTxn, StateVector, Transact};

use crate::models::documents::DocumentModel;

pub async fn load_document(db: &DatabaseConnection, doc_id: i64) -> ModelResult<Option<Vec<u8>>> {
    Ok(DocumentModel::get_by_id(db, doc_id).await?.map(|d| d.content))
}

pub async fn save_document(db: &DatabaseConnection, doc_id: i64, doc: &Doc) -> ModelResult<()> {
    let update = doc.transact().encode_diff_v1(&StateVector::default());
    let now = common::time::current_ms() as i64;
    DocumentModel::update_content(db, doc_id, update, now).await?;
    Ok(())
}
