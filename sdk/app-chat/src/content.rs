use std::collections::HashMap;

use prost::Message;
use proto::idl::entity;

pub enum ContentBody {
    Text(entity::MessageText),
    Image(entity::MessageImage),
    File(entity::MessageFile),
    RichText(entity::MessageRichText),
    Markdown(entity::MessageMarkdown),
    Forward(entity::MessageForward),
    System(entity::MessageSystem),
    Voice(entity::VoiceContent),
    Media(entity::MediaContent),
    Location(entity::LocationContent),
    Card(entity::CardContent),
}

pub fn build_content(tpy: i32, msg: &impl Message) -> Vec<u8> {
    msg.encode_to_vec()
}

pub fn parse_content(msg: &entity::Message) -> Option<ContentBody> {
    if msg.content.is_empty() {
        return None;
    }
    match msg.tpy {
        1 => entity::MessageText::decode(msg.content.as_slice())
            .ok()
            .map(ContentBody::Text),
        2 => entity::MessageImage::decode(msg.content.as_slice())
            .ok()
            .map(ContentBody::Image),
        3 => entity::MessageFile::decode(msg.content.as_slice())
            .ok()
            .map(ContentBody::File),
        4 => entity::VoiceContent::decode(msg.content.as_slice())
            .ok()
            .map(ContentBody::Voice),
        5 => entity::MediaContent::decode(msg.content.as_slice())
            .ok()
            .map(ContentBody::Media),
        7 => entity::LocationContent::decode(msg.content.as_slice())
            .ok()
            .map(ContentBody::Location),
        8 => entity::CardContent::decode(msg.content.as_slice())
            .ok()
            .map(ContentBody::Card),
        11 => entity::MessageRichText::decode(msg.content.as_slice())
            .ok()
            .map(ContentBody::RichText),
        13 => entity::MessageMarkdown::decode(msg.content.as_slice())
            .ok()
            .map(ContentBody::Markdown),
        14 => entity::MessageForward::decode(msg.content.as_slice())
            .ok()
            .map(ContentBody::Forward),
        15 => entity::MessageSystem::decode(msg.content.as_slice())
            .ok()
            .map(ContentBody::System),
        _ => None,
    }
}

pub fn generate_summary(tpy: i32, content: &[u8], sender_name: &str) -> String {
    if content.is_empty() {
        return String::new();
    }
    match tpy {
        1 => entity::MessageText::decode(content)
            .ok()
            .map(|t| t.text.chars().take(100).collect())
            .unwrap_or_default(),
        2 => "[图片]".to_string(),
        3 => entity::MessageFile::decode(content)
            .ok()
            .map(|f| format!("[文件] {}", f.name))
            .unwrap_or_default(),
        4 => entity::VoiceContent::decode(content)
            .ok()
            .map(|v| {
                if v.transcription_status == 2 && !v.transcription.is_empty() {
                    format!("[语音] {}", v.transcription.chars().take(80).collect::<String>())
                } else {
                    "[语音]".to_string()
                }
            })
            .unwrap_or_else(|| "[语音]".to_string()),
        5 => "[视频]".to_string(),
        7 => entity::LocationContent::decode(content)
            .ok()
            .map(|l| l.name)
            .unwrap_or_else(|| "[位置]".to_string()),
        8 => entity::CardContent::decode(content)
            .ok()
            .map(|c| c.title)
            .unwrap_or_else(|| "[卡片]".to_string()),
        11 => entity::MessageRichText::decode(content)
            .ok()
            .map(|_| "[富文本]".to_string())
            .unwrap_or_default(),
        13 => entity::MessageMarkdown::decode(content)
            .ok()
            .map(|m| text_from_markdown(&m.text).chars().take(100).collect())
            .unwrap_or_default(),
        14 => "[聊天记录]".to_string(),
        15 => entity::MessageSystem::decode(content)
            .ok()
            .map(|s| s.text)
            .unwrap_or_default(),
        _ => String::new(),
    }
}

fn text_from_markdown(md: &str) -> String {
    let mut text = String::new();
    for line in md.lines() {
        let stripped = line
            .strip_prefix("# ")
            .or_else(|| line.strip_prefix("## "))
            .or_else(|| line.strip_prefix("### "))
            .or_else(|| line.strip_prefix("- "))
            .or_else(|| line.strip_prefix("* "))
            .or_else(|| {
                let trimmed = line.trim_start();
                if trimmed.starts_with(|c: char| c.is_ascii_digit())
                    && trimmed.contains(". ")
                {
                    let dot_pos = trimmed.find(". ")?;
                    Some(&trimmed[dot_pos + 2..])
                } else {
                    None
                }
            })
            .unwrap_or(line);
        if !text.is_empty() {
            text.push(' ');
        }
        text.push_str(stripped);
    }
    text
}

pub fn render_summary(summary: &str, at_user_cache: &HashMap<i64, String>) -> String {
    if !summary.starts_with("^[") {
        return summary.to_string();
    }

    // ^[t][meta][content]
    let mut chars = summary.chars();
    chars.next(); // skip '^'
    if chars.next() != Some('[') {
        return summary.to_string();
    }

    let t = take_bracket_content(&mut chars);

    // skip [meta]
    let meta = if chars.as_str().starts_with('[') {
        chars.next();
        let meta_str = take_bracket_content(&mut chars);
        Some(meta_str)
    } else {
        None
    };

    // skip [content]
    let content = if chars.as_str().starts_with('[') {
        chars.next();
        let content_str = take_bracket_content(&mut chars);
        content_str
    } else {
        return summary.to_string();
    };

    match t.as_str() {
        "@" | "@a" => {
            let user_ids = meta
                .as_deref()
                .unwrap_or("")
                .split(',')
                .filter_map(|s| s.trim().parse::<i64>().ok())
                .collect::<Vec<_>>();
            if user_ids.is_empty() {
                content
            } else {
                let mut names = Vec::new();
                for uid in &user_ids {
                    if let Some(name) = at_user_cache.get(uid) {
                        names.push(name.clone());
                    }
                }
                if names.is_empty() {
                    content
                } else {
                    format!("@{}", names.join(", "))
                }
            }
        }
        _ => content,
    }
}

fn take_bracket_content(chars: &mut std::str::Chars) -> String {
    let mut content = String::new();
    loop {
        match chars.next() {
            Some(']') => break,
            Some(c) => content.push(c),
            None => break,
        }
    }
    content
}
