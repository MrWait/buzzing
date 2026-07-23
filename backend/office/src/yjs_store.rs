use loco_rs::prelude::*;
use sea_orm::ActiveValue;
use yrs::{Doc, GetString, ReadTxn, StateVector, Transact};

use crate::models::document_mentions::DocumentMentionModel;
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
    model.plain_text = ActiveValue::set(Some(plain_text.clone()));
    let _ = model.update(db).await?;
    // M8.2 保存时扫描 @ 提及
    let mentions = extract_mentions_from_plain(&plain_text);
    if !mentions.is_empty() {
        // 提取 user_id 作为 mentioned_by（从 doc.creator 近似，后续可改为实际保存者）
        let creator = DocumentModel::get_by_id(db, doc_id).await?.map(|d| d.creator).unwrap_or(0);
        let _ = DocumentMentionModel::replace(db, doc_id, creator, mentions, common::time::current_ms() as i64).await;
    }
    Ok(())
}

/// 从 `XmlFragmentRef::get_string()` 输出中剥离 `<tag>` 与 `<tag/>`，仅保留纯文本。
/// 简单实现：忽略引号内 `<` 的情况（编辑器输出可控，够用）。
pub fn strip_xml_tags(s: &str) -> String {
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

/// 从纯文本中抽取出所有 @mention 记录 (type, id)。
/// 格式：`@[type:id:label]` 或 `@user_id`（简化版取第一个空格前的词）。
/// 实际使用时由前端 mention node 直接提供结构化信息，此处为兜底解析。
pub fn extract_mentions_from_plain(text: &str) -> Vec<(String, String)> {
    let mut out = Vec::new();
    let bytes = text.as_bytes();
    let mut i = 0;
    while i < bytes.len() {
        if bytes[i] == b'@' {
            let start = i + 1;
            let mut end = start;
            while end < bytes.len() && !bytes[end].is_ascii_whitespace() && bytes[end] != b',' && bytes[end] != b'.' {
                end += 1;
            }
            if end > start {
                let mention = &text[start..end];
                // 支持 @[type:id:label] 格式
                if mention.starts_with('[') && mention.ends_with(']') {
                    let inner = &mention[1..mention.len()-1];
                    let parts: Vec<&str> = inner.splitn(3, ':').collect();
                    if parts.len() >= 2 {
                        out.push((parts[0].to_string(), parts[1].to_string()));
                    }
                } else if let Ok(uid) = mention.parse::<i64>() {
                    out.push(("user".into(), uid.to_string()));
                }
            }
            i = end;
        } else {
            i += 1;
        }
    }
    out
}
