# M5: 高级消息功能 — 设计方案

> 目标：提供语音/视频/定时/位置/卡片/翻译等高级消息能力。

---

## 1. 架构总览

```
┌──────────────────────────────────────────────────────────────┐
│ M5 新增内容                                                   │
│                                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────────────┐ │
│  │ Voice    │ │ Media    │ │ Location │ │ Card           │ │
│  │ 语音录制  │ │ 视频上传  │ │ 位置分享  │ │ 卡片模板渲染    │ │
│  │ ASR 转写  │ │ 缩略图    │ │ 地图展示  │ │ 交互按钮       │ │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └───────┬────────┘ │
│       │             │            │               │          │
│  ┌────┴─────────────┴────────────┴───────────────┴──────┐   │
│  │            store 模块 (文件存储)                       │   │
│  │   POST /api/files/upload → object_store → files 表    │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐     │
│  │ Translation│  │ Timer/Sched  │  │ Message Content   │     │
│  │ 翻译服务    │  │ 定时消息调度  │  │ 内容解析/生成摘要  │     │
│  └────────────┘  └──────────────┘  └──────────────────┘     │
└──────────────────────────────────────────────────────────────┘
```

**关键原则**：
- 所有多媒体文件（语音、视频）复用 `store` 模块的 `POST /api/files/upload` 上传接口
- 消息体 `content` 字段存储 protobuf 编码的结构化内容，各端按 `tpy` 分发解析
- 定时消息基于数据库轮询 + tokio 定时任务，不引入消息队列
- 翻译服务先集成外部 API（如 LibreTranslate），可插拔替换

---

## 2. 详细设计

### 2.1 语音消息 (M5-A)

#### 2.1.1 Proto

```protobuf
// entity.proto 补充
message VoiceContent {
    string file_id = 1;          // files 表 ID
    string url = 2;              // 下载 URL
    int32 duration_sec = 3;      // 语音时长（秒）
    int32 wave_form = 4;         // 波形图数据（可选）
    string transcription = 5;    // 转文字结果（初始为空，ASR 后填充）
    int32 transcription_status = 6; // 0=未转写, 1=转写中, 2=已完成
}

message TranscribeVoiceRequest {
    string message_id = 1;       // 消息 ID
}

message TranscribeVoiceResponse {
    string transcription = 1;    // 转写文本
}
```

**新增 Command**:

| Command | 值 | 方向 |
|---------|-----|------|
| `VOICE_TRANSCRIBE` | 1410 | C→S |

#### 2.1.2 后端

**发送语音消息**：纯透传，无特殊处理。`content = VoiceContent{file_id, url, duration_sec}` pb 编码 → `messages.content`。

**语音转文字 (ASR)**：
- 后端 `transcribe_voice` handler 接收消息 ID
- 从 `messages` 表读取 `content`，解析 `VoiceContent`
- 通过 ASR 服务（先集成本地 whisper 或调用第三方 API）转写
- 更新 `messages.content` 中的 `transcription` 字段
- 推送 `PushMessages` 通知发送方转写完成
- 可选异步：收到请求后立即返回 "转写中"，后台异步完成后再推

**ASR 集成策略**：
- MVP：调用 OpenAI Whisper API 或本地 whisper.cpp
- 预留接口 `trait AsrService { async fn transcribe(audio_data: &[u8]) -> Result<String> }`
- 配置项 `asr.provider = "openai" | "whisper_cpp" | "none"`

#### 2.1.3 SDK

- `VoiceContent` 解析支持（`content.rs`）
- `transcribe_voice` 命令封装
- `generate_summary` 返回 `"[语音]"`

#### 2.1.4 Flutter

- **录制**：使用 `record` 或 `flutter_sound` 包录制 m4a/ogg → 上传到 `POST /api/files/upload` → 构造 `VoiceContent` → 发消息
- **播放**：内联语音气泡，点击播放，显示波形/时长
- **转文字**：长按语音消息 → "转文字" → 调用 `VOICE_TRANSCRIBE` → 展示结果
- 未播放标记（红点）

---

### 2.2 视频消息 (M5-B)

#### 2.2.1 Proto

```protobuf
// entity.proto 补充
message MediaContent {
    string file_id = 1;          // files 表 ID
    string url = 2;              // 视频下载 URL
    string thumbnail_url = 3;    // 缩略图 URL
    int32 width = 4;
    int32 height = 5;
    int32 duration_sec = 6;      // 视频时长（秒）
    int64 file_size = 7;         // 文件大小
    string mime_type = 8;        // video/mp4 等
}
```

**注意**：无需新增 Command。视频消息的发送流程 = 上传 → 构造 `MediaContent` → 走标准 `MessageSend`。

#### 2.2.2 后端

- 纯透传，同语音。`content = MediaContent{...}` pb 编码存储
- 缩略图：上传时 store 模块已自动生成（`generate_thumbnail()` for images），视频需要额外用 `ffmpeg` 提取关键帧
- **视频缩略图生成**：可选功能，M5 MVP 可以先用默认视频图标替代

#### 2.2.3 SDK

- `MediaContent` 解析支持（`content.rs`）
- `generate_summary` 返回 `"[视频]"`

#### 2.2.4 Flutter

- **选择**：使用 `image_picker` 或 `file_picker` 选择视频 → 上传 store 模块 → 构造 `MediaContent` → 发消息
- **播放**：内联视频卡片，点击全屏播放（`video_player` 或 `chewie`）
- 展示缩略图 + 时长 + 播放按钮

---

### 2.3 位置消息 (M5-C)

#### 2.3.1 Proto

```protobuf
// entity.proto 补充
message LocationContent {
    string name = 1;             // 位置名称："北京市朝阳区xxx"
    string address = 2;          // 详细地址
    double latitude = 3;
    double longitude = 4;
    int32 zoom = 5;              // 地图缩放级别
    string map_url = 6;          // 静态地图图片 URL（可选）
}
```

#### 2.3.2 后端

- 纯透传，`content = LocationContent{...}` pb 编码存储

#### 2.3.3 SDK

- `LocationContent` 解析支持（`content.rs`）
- `generate_summary` 返回位置名称

#### 2.3.4 Flutter

- **选择**：位置选择器（集成高德/腾讯地图 SDK 或简单的地址搜索页）
- **展示**：内联位置卡片，显示静态地图缩略图 + 地址名称，点击打开地图 App
- MVP 方案：使用 `url_launcher` 打开 `https://maps.google.com/?q=lat,lng`

---

### 2.4 卡片消息 (M5-D)

#### 2.4.1 Proto

```protobuf
// entity.proto 补充
message CardContent {
    string title = 1;
    string description = 2;
    string icon_url = 3;         // 卡片图标
    string image_url = 4;        // 卡片大图
    string url = 5;              // 点击跳转链接
    repeated CardAction actions = 6;
}

message CardAction {
    string label = 1;            // 按钮文字
    string url = 2;              // 按钮链接
    int32 action_type = 3;       // 0=URL, 1=复制文本, 2=回调
    string value = 4;            // 对应 action 的值
}
```

#### 2.4.2 后端

- 纯透传。`content = CardContent{...}` pb 编码存储

#### 2.4.3 SDK + Flutter

- `CardContent` 解析 + `generate_summary` 返回标题
- Flutter 渲染：带图标/图片、标题、描述的卡片样式 + 底部操作按钮
- 点击按钮实现跳转 URL / 复制 / 回调

---

### 2.5 定时消息 (M5-E)

#### 2.5.1 Proto

```protobuf
// 新增 timer.proto
syntax = "proto3";
package timer;
import "entity.proto";

message ScheduleMessageRequest {
    int64 chat_id = 1;
    int64 send_at_ms = 2;       // 预定发送时间戳(ms)
    int32 tpy = 3;              // 消息类型
    bytes content = 4;          // 消息内容（同普通消息 content）
    int64 client_id = 5;        // 客户端去重 ID
    int64 at_user_id = 6;       // @指定用户（可选）
    repeated int64 at_user_ids = 7;
}

message ScheduleMessageResponse {
    int64 schedule_id = 1;      // 定时任务 ID
    int64 schedule_at_ms = 2;
}

message CancelScheduleRequest {
    int64 schedule_id = 1;
}

message CancelScheduleResponse {}

message GetScheduledMessagesRequest {
    int32 page = 1;
    int32 page_size = 2;
}

message GetScheduledMessagesResponse {
    repeated ScheduledMessage messages = 1;
    int32 total = 2;
}

message ScheduledMessage {
    int64 id = 1;
    int64 chat_id = 2;
    int64 send_at_ms = 3;
    int32 tpy = 4;
    bytes content = 5;
    int32 status = 6;           // 0=待发送, 1=已发送, 2=已取消
    int64 created_at_ms = 7;
}
```

**Command 补充**:

| Command | 值 | 方向 |
|---------|-----|------|
| `SCHEDULE_MESSAGE` | 1415 | C→S |
| `CANCEL_SCHEDULE` | 1416 | C→S |
| `GET_SCHEDULED_MESSAGES` | 1417 | C→S |

#### 2.5.2 DB 迁移

```sql
CREATE TABLE scheduled_messages (
    id BIGINT PRIMARY KEY,           -- Snowflake
    user_id BIGINT NOT NULL,         -- 发送者
    chat_id BIGINT NOT NULL,         -- 目标会话
    client_id BIGINT NOT NULL DEFAULT 0,
    tpy SMALLINT NOT NULL,           -- 消息类型
    content BYTEA NOT NULL,          -- 消息内容
    send_at_ms BIGINT NOT NULL,      -- 预定发送时间
    status SMALLINT NOT NULL DEFAULT 0, -- 0=待发送, 1=已发送, 2=已取消
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX idx_scheduled_user_status ON scheduled_messages(user_id, status);
CREATE INDEX idx_scheduled_send_at ON scheduled_messages(send_at_ms, status)
    WHERE status = 0;
```

#### 2.5.3 后端

**`schedule_message` handler**：
1. 验证 `send_at_ms > now`
2. 写入 `scheduled_messages` 表
3. 返回 `schedule_id`

**`cancel_schedule` handler**：
1. 校验 `user_id` 匹配
2. 设置 `status = 2`（已取消）

**`get_scheduled_messages` handler**：
- 查询当前用户待发送/已发送的定时消息列表

**定时调度器**：
```rust
// 启动时 spawn 一个 tokio 定时任务，每秒轮询一次
async fn scheduler_loop(ctx: AppContext) {
    let mut interval = tokio::time::interval(Duration::from_secs(1));
    loop {
        interval.tick().await;
        // 查询 send_at_ms <= now AND status = 0 的记录
        let msgs = ScheduledMessageModel::find_due(&ctx.db).await?;
        for msg in msgs {
            // 构造 SendMessageRequest 调用 message_send
            message_send(ctx, brief, packet, ws).await?;
            // 更新 status = 1
            ScheduledMessageModel::mark_sent(&ctx.db, msg.id).await?;
        }
    }
}
```

#### 2.5.4 SDK + Flutter

- SDK 封装 `schedule_message` / `cancel_schedule` / `get_scheduled_messages`
- Flutter：在消息输入区增加定时发送按钮 → 选择时间 → 确认定时
- 定时消息列表页：展示所有待发送/已发送的定时消息
- 消息气泡上展示定时发送标记（小闹钟图标）

---

### 2.6 消息翻译 (M5-F)

#### 2.6.1 Proto

```protobuf
// 新增 translate.proto
syntax = "proto3";
package translate;

message TranslateMessageRequest {
    int64 message_id = 1;
    int64 chat_id = 2;
    string target_lang = 3;     // "en", "zh", "ja"...
}

message TranslateMessageResponse {
    int64 message_id = 1;
    string original_text = 2;
    string translated_text = 3;
    string target_lang = 4;
    string source_lang = 5;     // 检测到的源语言
}

message GetTranslationLanguagesRequest {}

message GetTranslationLanguagesResponse {
    repeated TranslateLanguage languages = 1;
}

message TranslateLanguage {
    string code = 1;             // "zh", "en", "ja"...
    string name = 2;             // "中文", "English", "日本語"
}
```

**Command 补充**:

| Command | 值 | 方向 |
|---------|-----|------|
| `TRANSLATE_MESSAGE` | 1420 | C→S |
| `GET_TRANSLATION_LANGUAGES` | 1421 | C→S |

#### 2.6.2 后端

**翻译集成**：

```rust
#[async_trait]
trait TranslationService: Send + Sync {
    async fn translate(&self, text: &str, target: &str, source: Option<&str>) -> Result<TranslationResult>;
    async fn detect(&self, text: &str) -> Result<String>;
    fn supported_languages(&self) -> Vec<Language>;
}
```

MVP 实现选择：

| 方案 | 优点 | 缺点 |
|------|------|------|
| **LibreTranslate** (自部署) | 免费、隐私安全 | 需要额外部署服务，翻译质量一般 |
| **DeepSeek API** | 质量好，价格低 | 需要 API key |
| **OpenAI GPT API** | 质量最好 | 价格贵 |
| **百度翻译 API** | 国内可用，便宜 | 需要注册 |

推荐 MVP 用 **LibreTranslate 自部署**，后期可切换。

**`translate_message` handler**：
1. 根据 `message_id` 读取 `messages.content`
2. 解析 content 提取文本（支持 TEXT、RICH_TEXT_QUILL、MARKDOWN 等）
3. 调用翻译服务
4. 返回翻译结果（不修改原消息）

#### 2.6.3 SDK

- `translate_message` / `get_translation_languages` 命令封装
- 无 content 类型变更

#### 2.6.4 Flutter

- 长按消息 → "翻译" → 在原消息下方展示翻译结果
- 语言选择：默认跟随系统语言
- 翻译结果缓存：同一消息不重复请求

---

## 3. 实现顺序与依赖

```
M5-A: 语音消息 ───→  M5-B: 视频消息 （共享 store 上传流程）
                          │
M5-C: 位置消息 ───→  M5-D: 卡片消息 （独立，可并行）
                          │
M5-E: 定时消息 ───→  依赖 send_message 基础
                          │
M5-F: 消息翻译 ───→  依赖 content 解析基础
```

**建议执行顺序**：
1. **M5-A 语音消息** + **M5-D 卡片消息**（并行，互相独立）
2. **M5-E 定时消息**（后端最复杂，优先做）
3. **M5-F 消息翻译**（依赖内容解析）
4. **M5-B 视频消息**（与语音共享上传流程）
5. **M5-C 位置消息**（简单，可穿插）
6. **各端 Content 解析 + UI**（贯穿全程）

---

## 4. Proto 补充清单

| Proto 文件 | 新增内容 |
|-----------|---------|
| `entity.proto` | `VoiceContent`, `MediaContent`, `LocationContent`, `CardContent`, `CardAction` |
| `timer.proto` | `ScheduleMessageRequest/Response`, `CancelScheduleRequest/Response`, `GetScheduledMessagesRequest/Response`, `ScheduledMessage` |
| `translate.proto` | `TranslateMessageRequest/Response`, `GetTranslationLanguagesRequest/Response`, `TranslateLanguage` |

## 5. Command 补充清单

| Command | 值 | 所属 |
|---------|-----|------|
| `VOICE_TRANSCRIBE` | 1410 | M5-A |
| `SCHEDULE_MESSAGE` | 1415 | M5-E |
| `CANCEL_SCHEDULE` | 1416 | M5-E |
| `GET_SCHEDULED_MESSAGES` | 1417 | M5-E |
| `TRANSLATE_MESSAGE` | 1420 | M5-F |
| `GET_TRANSLATION_LANGUAGES` | 1421 | M5-F |

## 6. DB 迁移清单

| 迁移 | 表 |
|------|-----|
| M5-E | `scheduled_messages` |

## 7. 安全性

| 场景 | 措施 |
|------|------|
| 语音转文字 | 只允许消息发送者或群成员调用 |
| 定时消息取消 | 只能取消自己的定时消息 |
| 翻译 | 只翻译自己有权限查看的消息 |
| 文件上传 | 复用 store 模块的认证（需登录 token） |
