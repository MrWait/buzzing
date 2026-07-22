# M5: 高级消息功能

> 设计文档见 `docs/im/m5_design.md`。

---

## Step M5-A: 语音消息

- [x] **M5-A.1** Proto — `entity.proto` 补充 `VoiceContent` message
- [x] **M5-A.2** Proto — 新增 `TranscribeVoiceRequest/Response`
- [x] **M5-A.3** `proto/command.proto` — 新增 `VOICE_TRANSCRIBE(1410)`
- [x] **M5-A.4** `proto/proto.toml` / proto.yaml — 无变更（entity.proto、command.proto 已在列表中）
- [x] **M5-A.5** 后端 — `backend/im/src/voice.rs` 实现 `transcribe_voice` handler
- [x] **M5-A.6** 后端 — ASR 服务抽象 `trait AsrService` + StubAsr 实现
- [x] **M5-A.7** 后端 — 注册 Command::VoiceTranscribe 路由
- [x] **M5-A.8** SDK — `voice.rs` 新增 `transcribe_voice` 命令封装
- [x] **M5-A.9** SDK — `content.rs` 补充 `VoiceContent` 解析 + `generate_summary`
- [x] **M5-A.10** Flutter Dart — `im_ext.pb.dart` 补充 VoiceContent / TranscribeVoiceRequest/Response
- [x] **M5-A.11** Flutter — 语音录制 UI
- [x] **M5-A.12** Flutter — 语音消息气泡
- [x] **M5-A.13** Flutter — 转文字功能
- [x] **M5-A.14** Flutter — ImController 集成 voice 相关方法

---

## Step M5-B: 视频消息

- [x] **M5-B.1** Proto — `entity.proto` 补充 `MediaContent` message
- [x] **M5-B.2** SDK — `content.rs` 补充 `MediaContent` 解析 + `generate_summary`（已含在 A.9 中）
- [x] **M5-B.3** Flutter Dart — `im_ext.pb.dart` 补充 MediaContent / LocationContent / CardContent / CardAction
- [x] **M5-B.4** Flutter — 视频选择器（ImagePicker → 上传 store → 构造 MediaContent → 发消息）
- [x] **M5-B.5** Flutter — 视频消息气泡（缩略图 + 时长 + 播放按钮）
- [x] **M5-B.6** 后端 — 视频缩略图生成（services::generate_video_thumbnail + upload handler）

---

## Step M5-C: 位置消息

- [x] **M5-C.1** Proto — `entity.proto` 补充 `LocationContent` message
- [x] **M5-C.2** SDK — `content.rs` 补充 `LocationContent` 解析 + `generate_summary` 返回位置名称（已含在 A.9 中）
- [x] **M5-C.3** Flutter Dart — `im_ext.pb.dart` 补充 LocationContent（已含在 B.3 中）
- [x] **M5-C.4** Flutter — 位置选择器页（Nominated 搜索 → 选点 → 发消息）
- [x] **M5-C.5** Flutter — 位置消息气泡（OSM 静态地图缩略图 + 地址名 + 点击打开地图 App）

---

## Step M5-D: 卡片消息

- [x] **M5-D.1** Proto — `entity.proto` 补充 `CardContent` + `CardAction` message
- [x] **M5-D.2** SDK — `content.rs` 补充 `CardContent` 解析 + `generate_summary` 返回标题（已含在 A.9 中）
- [x] **M5-D.3** Flutter Dart — `im_ext.pb.dart` 补充 CardContent / CardAction（已含在 B.3 中）
- [x] **M5-D.4** Flutter — 卡片消息气泡（图标/图片 + 标题 + 描述 + 操作按钮）
- [x] **M5-D.5** Flutter — 按钮交互（URL 跳转 / 复制文本 / SnackBar 回调）

---

## Step M5-E: 定时消息

- [x] **M5-E.1** Proto — 新建 `proto/timer.proto`（ScheduleMessageRequest/Response, Cancel, GetList, ScheduledMessage）
- [x] **M5-E.2** `proto/command.proto` — 新增 SCHEDULE_MESSAGE(1415), CANCEL_SCHEDULE(1416), GET_SCHEDULED_MESSAGES(1417)（含 Flutter command.pbenum.dart）
- [x] **M5-E.3** `proto/proto.toml` + `backend/proto/proto.yaml` + `sdk/proto/proto.yaml` — 注册 timer.proto
- [x] **M5-E.4** `backend/proto/src/lib.rs` + `sdk/proto/src/lib.rs` — 注册 timer 模块
- [x] **M5-E.5** Flutter Dart — `im_ext.pb.dart` 补充 ScheduleMessageRequest/Response / CancelSchedule / GetScheduledMessages / ScheduledMessage
- [x] **M5-E.6** DB 迁移 — 创建 `scheduled_messages` 表（idx_scheduled_user_status + idx_scheduled_send_at 索引）
- [x] **M5-E.7** 后端 — `backend/im/src/scheduler.rs` 实现 `schedule_message` handler（写入 scheduled_messages 表）
- [x] **M5-E.8** 后端 — `cancel_schedule` handler（校验 user_id + status=2）
- [x] **M5-E.9** 后端 — `get_scheduled_messages` handler（分页查询）
- [x] **M5-E.10** 后端 — `SchedulerService` 定时轮询任务（每秒查到期消息 → 调 send_message → 标记已发送）
- [x] **M5-E.11** 后端 — 注册 Command::ScheduleMessage / CancelSchedule / GetScheduledMessages 路由
- [x] **M5-E.12** 后端 — 在 AppIm::serve 中启动 scheduler 后台任务
- [x] **M5-E.13** SDK — `scheduler.rs` 新增 3 个命令封装
- [x] **M5-E.14** Flutter — 消息输入区定时发送按钮（长按发送按钮 → 时间选择器 → 确认定时）
- [x] **M5-E.15** Flutter — 定时消息列表页（待发送/已发送/已取消 + 取消操作）
- [ ] **M5-E.16** Flutter — 消息气泡定时标记（待 Message proto 增加 schedule_id 字段后实现）
---

## Step M5-F: 消息翻译

- [x] **M5-F.1** Proto — 新建 `proto/translate.proto`（TranslateMessageRequest/Response, GetTranslationLanguages, TranslateLanguage）
- [x] **M5-F.2** `proto/command.proto` — 新增 TRANSLATE_MESSAGE(1420), GET_TRANSLATION_LANGUAGES(1421)（含 Flutter command.pbenum.dart）
- [x] **M5-F.3** `proto/proto.toml` + `backend/proto/proto.yaml` + `sdk/proto/proto.yaml` — 注册 translate.proto
- [x] **M5-F.4** `backend/proto/src/lib.rs` + `sdk/proto/src/lib.rs` — 注册 translate 模块
- [x] **M5-F.5** Flutter Dart — `im_ext.pb.dart` 补充 TranslateMessageRequest/Response / GetTranslationLanguages / TranslateLanguage
- [x] **M5-F.6** 后端 — 翻译服务抽象 `TranslationService` trait + `StubTranslation` 实现（可替换为 LibreTranslate/DeepSeek）
- [x] **M5-F.7** 后端 — `backend/im/src/translate.rs` 实现 `translate_message` handler（解析 content → 调用翻译 → 返回结果）
- [x] **M5-F.8** 后端 — `get_translation_languages` handler（返回支持的语言列表）
- [x] **M5-F.9** 后端 — 注册 Command::TranslateMessage / GetTranslationLanguages 路由
- [x] **M5-F.10** SDK — `translate.rs` 新增 2 个命令封装
- [x] **M5-F.11** Flutter — 长按消息菜单 → "翻译" → 在原消息下方展示翻译结果
- [x] **M5-F.12** Flutter — 翻译结果缓存（同一消息不重复请求）
