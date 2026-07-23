use axum::debug_handler;
use axum::response::{Html, IntoResponse};
use loco_rs::prelude::*;
use yrs::{GetString, ReadTxn, Transact};

use crate::models::documents::DocumentModel;
use crate::permission::{require_role, Role};
use common::model::UserBrief;

/// 将 Yjs XmlFragment 的 XML 字符串（由 get_string() 产生）转换为 HTML。
/// 输入示例: `<paragraph>Hello</paragraph><heading level="1">Title</heading>`
fn yjs_xml_to_html(xml: &str) -> String {
    let mut html = String::with_capacity(xml.len() * 2);
    let mut in_tag = false;
    let mut tag_buf = String::new();
    // 栈中存储期待对应的 HTML 闭合标签
    let mut close_stack: Vec<String> = Vec::new();

    for c in xml.chars() {
        if c == '<' && !in_tag {
            in_tag = true;
            tag_buf.clear();
        } else if c == '>' && in_tag {
            in_tag = false;
            let tag = tag_buf.trim();
            if tag.starts_with('/') {
                let name = tag[1..].trim();
                if let Some(expected_close) = close_stack.pop() {
                    html.push_str(&expected_close);
                } else {
                    // fallback: 无 stck 时直接输出标签
                    html.push_str("</");
                    html.push_str(name);
                    html.push('>');
                }
            } else if tag.ends_with('/') {
                let inner = tag.trim_end_matches('/').trim();
                let (name, attrs) = parse_tag_attrs(inner);
                if let Some(self_closing) = self_closing_to_html(&name, &attrs) {
                    html.push_str(&self_closing);
                }
                // 自闭合标签不修改栈
            } else {
                let (name, attrs) = parse_tag_attrs(tag);
                let mut close_html = String::new();
                if let Some(open) = open_tag_to_html(&name, &attrs, &mut close_html) {
                    html.push_str(&open);
                    close_stack.push(close_html);
                } else {
                    // 不识别的标签 — 原样输出
                    html.push('<');
                    html.push_str(&name);
                    for (k, v) in &attrs {
                        html.push(' ');
                        html.push_str(k);
                        html.push_str("=\"");
                        html.push_str(v);
                        html.push('"');
                    }
                    html.push('>');
                    close_stack.push(format!("</{}>", name));
                }
            }
        } else if in_tag {
            tag_buf.push(c);
        } else {
            // 文本内容需要 HTML 转义（Yjs 的 XML 文本节点是原始文本）
            match c {
                '&' => html.push_str("&amp;"),
                '<' => html.push_str("&lt;"),
                '>' => html.push_str("&gt;"),
                '"' => html.push_str("&quot;"),
                _ => html.push(c),
            }
        }
    }

    // 关闭栈中剩余标签（容错）
    while let Some(close) = close_stack.pop() {
        html.push_str(&close);
    }

    html
}

/// 解析 `name k1="v1" k2="v2"` 返回 (标签名, 属性列表)
fn parse_tag_attrs(tag: &str) -> (String, Vec<(String, String)>) {
    let parts: Vec<&str> = tag.splitn(2, char::is_whitespace).collect();
    let name = parts[0].to_string();
    if parts.len() < 2 {
        return (name, Vec::new());
    }
    let mut attrs = Vec::new();
    let mut key = String::new();
    let mut val = String::new();
    let mut reading_key = true;
    let mut in_quote = false;
    let mut quote_char = '"';
    for c in parts[1].chars() {
        if in_quote {
            if c == quote_char {
                in_quote = false;
                attrs.push((std::mem::take(&mut key), std::mem::take(&mut val)));
                reading_key = true;
            } else {
                val.push(c);
            }
        } else if c == '=' {
            reading_key = false;
        } else if c == '"' || c == '\'' {
            in_quote = true;
            quote_char = c;
        } else if !c.is_whitespace() && reading_key {
            key.push(c);
        }
        // 跳过 attr 间的空白
    }
    (name, attrs)
}

/// 打开标签 -> (HTML opener, 用于栈的 HTML closer)
/// 返回 None 表示无法识别（将原样输出）
fn open_tag_to_html(name: &str, attrs: &[(String, String)], close_out: &mut String) -> Option<String> {
    match name {
        "paragraph" => {
            close_out.push_str("</p>");
            Some("<p>".into())
        }
        "heading" => {
            let level = attrs
                .iter()
                .find(|(k, _)| k == "level")
                .map(|(_, v)| v.as_str())
                .unwrap_or("1");
            close_out.push_str("</h");
            close_out.push_str(level);
            close_out.push('>');
            let mut open = String::from("<h");
            open.push_str(level);
            open.push('>');
            Some(open)
        }
        "bulletlist" => {
            close_out.push_str("</ul>");
            Some("<ul>".into())
        }
        "orderedlist" => {
            close_out.push_str("</ol>");
            Some("<ol>".into())
        }
        "listitem" => {
            close_out.push_str("</li>");
            Some("<li>".into())
        }
        "blockquote" => {
            close_out.push_str("</blockquote>");
            Some("<blockquote>".into())
        }
        "codeblock" => {
            close_out.push_str("</code></pre>");
            Some("<pre><code>".into())
        }
        "text" => {
            let is_code = attrs.iter().any(|(k, v)| k == "code" && v == "true");
            if is_code {
                close_out.push_str("</code>");
                return Some("<code>".into());
            }
            let has_link = attrs.iter().any(|(k, _)| k == "link");
            let has_bold = attrs.iter().any(|(k, v)| k == "bold" && v == "true");
            let has_italic = attrs.iter().any(|(k, v)| k == "italic" && v == "true");
            let has_strike = attrs.iter().any(|(k, v)| k == "strike" && v == "true");
            // 按入栈顺序的逆序输出关闭标签
            if has_strike { close_out.insert_str(0, "</s>"); }
            if has_italic { close_out.insert_str(0, "</em>"); }
            if has_bold { close_out.insert_str(0, "</strong>"); }
            if has_link { close_out.insert_str(0, "</a>"); }
            if is_code { close_out.insert_str(0, "</code>"); }

            let mut open = String::new();
            if is_code {
                open.push_str("<code>");
            } else {
                if let Some(href) = attrs.iter().find(|(k, _)| k == "link").map(|(_, v)| v.as_str()) {
                    open.push_str("<a href=\"");
                    open.push_str(href);
                    open.push_str("\">");
                }
                if has_bold { open.push_str("<strong>"); }
                if has_italic { open.push_str("<em>"); }
                if has_strike { open.push_str("<s>"); }
            }
            Some(open)
        }
        _ => None,
    }
}

fn self_closing_to_html(name: &str, attrs: &[(String, String)]) -> Option<String> {
    match name {
        "horizontalrule" => Some("<hr>".into()),
        "hardbreak" => Some("<br>".into()),
        "image" => {
            let src = attrs
                .iter()
                .find(|(k, _)| k == "src")
                .map(|(_, v)| v.as_str())
                .unwrap_or("");
            let alt = attrs
                .iter()
                .find(|(k, _)| k == "alt")
                .map(|(_, v)| v.as_str())
                .unwrap_or("");
            Some(format!("<img src=\"{}\" alt=\"{}\">", src, alt))
        }
        _ => None,
    }
}

#[debug_handler]
pub async fn render(
    auth: auth::JWT,
    Path(id): Path<i64>,
    State(ctx): State<AppContext>,
    Query(params): Query<std::collections::HashMap<String, String>>,
) -> Result<Response> {
    let claim = UserBrief::from_string(&auth.claims.pid)?;
    require_role(&ctx, claim.id, id, Role::Viewer).await?;

    let doc = DocumentModel::get_by_id(&ctx.db, id)
        .await?
        .ok_or(Error::NotFound)?;

    let html_content = {
        let manager = crate::ws::YJS_MANAGER
            .get()
            .ok_or_else(|| Error::InternalServerError)?;
        let state = manager.get_or_create(id).await?;
        let txn = state.doc.transact();
        txn.get_xml_fragment("prosemirror")
            .map(|f| {
                let xml_str = f.get_string(&txn);
                yjs_xml_to_html(&xml_str)
            })
            .unwrap_or_default()
    };

    let fmt = params.get("format").map(|s| s.as_str()).unwrap_or("html");

    if fmt == "fragment" {
        Ok(Html(html_content).into_response())
    } else {
        let title = doc.title;
        let created_at = doc.created_at.format("%Y-%m-%d %H:%M UTC").to_string();
        let updated_at = doc.updated_at.format("%Y-%m-%d %H:%M UTC").to_string();
        let content = &html_content;
        let page = format!(
            r#"<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title} — Buzzing Office</title>
<style>
  body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; max-width: 800px; margin: 0 auto; padding: 24px; color: #333; line-height: 1.6; }}
  .meta {{ color: #999; font-size: 13px; margin-bottom: 24px; border-bottom: 1px solid #eee; padding-bottom: 12px; }}
  h1, h2, h3, h4, h5, h6 {{ margin-top: 24px; margin-bottom: 12px; font-weight: 600; }}
  p {{ margin: 8px 0; }}
  ul, ol {{ padding-left: 24px; }}
  pre {{ background: #f5f5f5; padding: 12px; border-radius: 6px; overflow-x: auto; }}
  code {{ background: #f0f0f0; padding: 2px 4px; border-radius: 3px; font-size: 0.9em; }}
  pre code {{ background: transparent; padding: 0; }}
  blockquote {{ border-left: 3px solid #ddd; margin-left: 0; padding-left: 16px; color: #666; }}
  img {{ max-width: 100%; height: auto; }}
</style>
</head>
<body>
<h1>{title}</h1>
<div class="meta">创建于 {created_at} · 更新于 {updated_at}</div>
<div class="content">{content}</div>
</body>
</html>"#,
        );
        Ok(Html(page).into_response())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_paragraph() {
        assert_eq!(yjs_xml_to_html("<paragraph>Hello</paragraph>"), "<p>Hello</p>");
    }

    #[test]
    fn test_heading() {
        assert_eq!(yjs_xml_to_html("<heading level=\"1\">T</heading>"), "<h1>T</h1>");
        assert_eq!(yjs_xml_to_html("<heading level=\"2\">T</heading>"), "<h2>T</h2>");
    }

    #[test]
    fn test_bold() {
        assert_eq!(
            yjs_xml_to_html("<paragraph>a<text bold=\"true\">b</text>c</paragraph>"),
            "<p>a<strong>b</strong>c</p>"
        );
    }

    #[test]
    fn test_italic_link() {
        assert_eq!(
            yjs_xml_to_html("<paragraph><text italic=\"true\" link=\"https://x.com\">link</text></paragraph>"),
            "<p><a href=\"https://x.com\"><em>link</em></a></p>"
        );
    }

    #[test]
    fn test_list() {
        assert_eq!(
            yjs_xml_to_html("<bulletlist><listitem>A</listitem><listitem>B</listitem></bulletlist>"),
            "<ul><li>A</li><li>B</li></ul>"
        );
    }

    #[test]
    fn test_self_closing() {
        assert_eq!(
            yjs_xml_to_html("<paragraph>a<hardbreak/>b</paragraph>"),
            "<p>a<br>b</p>"
        );
    }

    #[test]
    fn test_code_block() {
        assert_eq!(
            yjs_xml_to_html("<codeblock>fn main()</codeblock>"),
            "<pre><code>fn main()</code></pre>"
        );
    }

    #[test]
    fn test_html_escape() {
        // Yjs 文本节点中 & < > 是字面量，需要转义为 HTML 实体
        assert_eq!(
            yjs_xml_to_html("<paragraph>A & B < C > D</paragraph>"),
            "<p>A &amp; B &lt; C &gt; D</p>"
        );
    }

    #[test]
    fn test_nested_marks() {
        assert_eq!(
            yjs_xml_to_html("<paragraph><text bold=\"true\" italic=\"true\">bi</text></paragraph>"),
            "<p><strong><em>bi</em></strong></p>"
        );
    }

    #[test]
    fn test_image() {
        assert_eq!(
            yjs_xml_to_html("<image src=\"https://x.com/a.png\" alt=\"pic\"/>"),
            "<img src=\"https://x.com/a.png\" alt=\"pic\">"
        );
    }
}
