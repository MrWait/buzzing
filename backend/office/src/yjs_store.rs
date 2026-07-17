use loco_rs::prelude::*;
use sea_orm::ActiveValue;
use yrs::{Doc, GetString, ReadTxn, StateVector, Transact};

use crate::models::documents::DocumentModel;

pub async fn load_document(db: &DatabaseConnection, doc_id: i64) -> ModelResult<Option<Vec<u8>>> {
    Ok(DocumentModel::get_by_id(db, doc_id).await?.map(|d| d.content))
}

/// 保存 Yjs 文档：更新 content(BYTEA) + version + plain_text (全文搜索用)
pub async fn save_document(db: &DatabaseConnection, doc_id: i64, doc: &Doc) -> ModelResult<()> {
    let (update, plain_text) = {
        let txn = doc.transact();
        let update = txn.encode_diff_v1(&StateVector::default());
        // 抽取纯文本用于全文搜索。ProseMirror 使用 XmlFragment 'prosemirror' 作为根。
        let fragment = txn.get_xml_fragment("prosemirror");
        let plain = fragment
            .map(|f| f.get_string(&txn))
            .map(|s| strip_xml_tags(&s))
            .unwrap_or_default();
        (update, plain)
    };
    let now = common::time::current_ms() as i64;
    let mut model: <base::models::_entities::documents::Entity as sea_orm::EntityTrait>::ActiveModel =
        base::models::_entities::documents::Entity::find_by_id(doc_id)
            .one(db)
            .await?
            .ok_or_else(|| ModelError::EntityNotFound)?
            .into();
    model.content = ActiveValue::set(update);
    model.version = ActiveValue::set(now);
    model.plain_text = ActiveValue::set(Some(plain_text));
    let _ = model.update(db).await?;
    Ok(())
}

/// 从 `XmlFragmentRef::get_string()` 输出中剥离 `<tag>` 与 `<tag/>`，仅保留纯文本。
/// 简单实现：忽略引号内 `<` 的情况（编辑器输出可控，够用）。
fn strip_xml_tags(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    let mut in_tag = false;
    let mut last_char_was_space = false;
    for c in s.chars() {
        if in_tag {
            if c == '>' {
                in_tag = false;
                if !last_char_was_space {
                    out.push(' ');
                    last_char_was_space = true;
                }
            }
        } else if c == '<' {
            in_tag = true;
        } else {
            out.push(c);
            last_char_was_space = c.is_whitespace();
        }
    }
    out.split_whitespace().collect::<Vec<_>>().join(" ")
}
