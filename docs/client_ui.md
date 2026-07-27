# Flutter 客户端 UI 架构

## 概述

Flutter 客户端支持 **桌面端 (Windows/macOS/Linux)** 和 **移动端 (Android/iOS)** 双平台，通过 `flutter_rust_bridge` 调用 Rust SDK。

整体设计风格参考飞书（Lark），使用响应式布局系统适配不同屏幕尺寸。

---

## 目录结构

```
buzzing/lib/
├── main.dart                # 入口 (多窗口 + mobile 入口)
├── app.dart                 # BuzzingApp 根组件
│
├── controller/
│   ├── app_controller.dart  # 应用生命周期、子窗口管理、本地通知
│   ├── sdk_controller.dart  # FFI 桥接 (Rust SDK invoke/push)
│   └── im.dart              # IM 核心状态 (feeds/messages/threads/typing/presence)
│
├── provider/
│   ├── app_provider.dart
│   ├── app_state_provider.dart  # Theme/language/bg 状态
│   ├── sdk_provider.dart
│   ├── im_provider.dart
│   ├── office_provider.dart
│   └── page_providers.dart      # 各页面 Logic Provider
│
├── event/
│   └── event_bus.dart
│
├── router/
│   └── router.dart          # GoRouter 路由配置
│
├── routes/
│   ├── app_routes.dart      # 路由常量
│   └── app_navigator.dart   # 导航辅助方法
│
├── models/
│   ├── model.dart           # FeedModel 等业务模型
│   ├── const.dart           # ConstKey (KeyFeedList / KeyChatMessage / KeyBadge)
│   └── idl/                 # Dart Protobuf 生成代码 (gitignored, build.dart 生成)
│
├── page/
│   ├── splash/              # 启动页 (SDK 初始化 + 自动登录)
│   ├── login/               # 登录页 (手机/邮箱 + 密码/SMS)
│   │
│   ├── im/                  # IM 模块 (响应式容器)
│   │   └── im_view.dart     # 根据宽度选择 mobile/desktop 布局
│   ├── feed/                # 会话列表页
│   │   ├── feed_view.dart
│   │   └── feed_logic.dart
│   ├── chat/                # 聊天页
│   │   ├── chat_view.dart
│   │   ├── chat_logic.dart
│   │   ├── group_profile_page.dart
│   │   ├── member_list_page.dart
│   │   ├── join_requests_page.dart
│   │   └── invite_links_page.dart
│   │
│   ├── contact/             # 通讯录 (组织架构树)
│   ├── calendar/            # 日历 (月/周/日/计划视图)
│   ├── meeting/             # 会议管理 + WebRTC
│   ├── vc/                  # 视频会议独立窗口 (桌面子窗口 / 移动端全屏)
│   ├── office/              # 协作文档
│   ├── search/              # 全局搜索
│   ├── setting/             # 设置 (主题、语言)
│   ├── openapp/             # 开放平台 (应用列表、创建、详情)
│   ├── screenshot/          # 桌面端截屏 (仅桌面)
│   └── error_page.dart
│
├── widget/                  # 可复用组件
│   ├── navigate_bar.dart     # 桌面 NaviBar (64px 侧边栏)
│   ├── bottom_navi_bar.dart  # 移动端 BottomNavBar (5 tabs)
│   ├── header_bar.dart       # 桌面顶栏 (窗口控制按钮)
│   ├── app_view.dart         # App 根容器 (FocusDetector + LayoutBuilder + EasyLoading)
│   ├── feedcard.dart         # 会话列表项 (头像、名称、摘要、角标)
│   ├── message.dart          # 消息气泡 (1351行, 全部消息类型)
│   ├── message_input.dart    # 消息输入框 (Quill 编辑器 + 工具栏)
│   ├── avatar.dart           # 头像组件
│   ├── button.dart           # 按钮 + NaviButton
│   ├── personal.dart         # 用户头像弹窗 (PersonalPopup)
│   ├── forward_picker.dart   # 转发选择器
│   ├── member_picker/        # 成员选择器
│   ├── profile.dart          # 用户/群组资料展示
│   ├── search_dialog.dart    # 搜索对话框
│   ├── sticker.dart          # 贴纸
│   ├── calendar_creator.dart # 日历创建器
│   ├── calendar_event_utils.dart
│   ├── color_picker.dart
│   ├── create_event.dart
│   ├── schedule_creator.dart
│   ├── schedule_detail_page.dart
│   ├── draft_input.dart      # 文档编辑器输入(Office)
│   ├── loading_view.dart     # Loading 遮罩
│   ├── focus_detector.dart
│   ├── touch_close_keyboard.dart
│   ├── never_overscroll_indicator.dart
│   └── im_widget.dart        # IM 工具方法 (showToast)
│
├── res/
│   ├── theme.dart           # BuzzingTheme (ThemeExtension) + AppTheme (light/dark)
│   └── images.dart          # 图片资源路径
│
├── i18n/                    # 多语言 (slang, zh_CN / en_US)
│
├── utils/                   # 工具类
│   ├── screen_ext.dart      # ScreenUtil (响应式缩放)
│   ├── data_persistence.dart
│   ├── logger_util.dart
│   └── ...
│
└── ffi/                     # flutter_rust_bridge 生成的 FFI
    ├── rust/
    └── cpp/
```

---

## 状态管理

### Riverpod 架构

| Provider | 类型 | 职责 |
|----------|------|------|
| `imProvider` | `Provider<ImController>` | IM 核心 (ChangeNotifier) |
| `sdkProvider` | `Provider<SdkController>` | FFI 桥接 (ChangeNotifier) |
| `appStateProvider` | `NotifierProvider<AppStateNotifier, AppState>` | 主题/语言/后台状态 |
| `appControllerProvider` | `Provider<AppController>` | 应用生命周期 |

Page Logic Provider 使用 `Provider.autoDispose`：

| Provider | 绑定页面 |
|----------|---------|
| `loginLogicProvider` | LoginPage |
| `splashLogicProvider` | SplashPage |
| `calendarLogicProvider` | CalendarPage |
| `meetingHomeLogicProvider` | MeetingHomePage |
| `meetingLogicProvider` | MeetingPage (VC) |
| `contactLogicProvider` | ContactPage |
| `chatLogicProvider` | ChatPage |
| `feedLogicProvider` | FeedPage |
| `officeLogicProvider` | OfficePage |

### ImController (核心)

位于 `controller/im.dart`，`ChangeNotifier` 单例，驻留内存：

```
ImController
├── entity           # Entity 缓存 (feeds / chats / messages / users)
├── feedList         # 排序后的会话列表 (List<FeedModel>)
├── messagePosList   # 消息位置索引 (List<MessageIndex>)
├── chatId           # 当前聊天 ID
├── userId           # 当前用户 ID
│
├── fetchFeed()              # 拉取会话列表
├── loadMessage(chatId, pos, count)
├── sendMessage(chatId, content)
├── mergeEntity(entity)      # 合并推送/响应数据
├── updateFeedList()         # 重建 feedList (过滤已解散等)
└── enterChat(feedId)        # 进入聊天
```

### 事件总线

`EventBus` 使用 `StreamController.broadcast`，发布事件：

| 事件 | 触发时机 |
|------|---------|
| `logined` | SDK 登录成功 |
| `messageUpdate` | 消息变更 |
| `feedlistUpdate` | Feed 列表变更 |

---

## 导航与路由

### GoRouter 路由表

```
ShellRoute (BottomNavBar — 仅移动端)
├── /splash          → SplashPage
├── /login           → LoginPage
├── /im              → ImPage (响应式容器)
│   └── /im/chat/:id → ChatPage (移动端 push)
├── /calendar        → CalendarPage
├── /meeting         → MeetingPage
├── /contact         → ContactPage
├── /office          → OfficePage
├── /search          → SearchPage
├── /settings        → SettingsPage
├── /open-platform   → OpenAppListPage
├── /group_profile/:chatId
├── /member_list/:chatId
├── /join_requests/:chatId
└── /invite_links/:chatId
```

### 页面过渡

| 平台 | 过渡方式 |
|------|---------|
| 桌面 (≥900px) | `CustomTransitionPage` — 零时长，无动画 |
| 移动/平板 (<900px) | `MaterialPageRoute` — 平台默认滑动过渡 |

---

## 响应式布局系统

### 断点定义

| 范围 | 分类 | 目标设备 |
|------|------|---------|
| `< 600px` | **mobile** | 手机竖屏 |
| `600–899px` | **tablet** | 平板竖屏、小折叠屏 |
| `≥ 900px` | **desktop** | 桌面、平板横屏、大屏 |

### IM 模块布局

```
mobile (<600px):
┌────────────────────┐
│     FeedList       │  ← 全屏，带搜索栏
│   (会话列表)       │
├────────────────────┤
│ 消息│日历│会议│... │  ← BottomNavBar (5 tabs)
└────────────────────┘

     ↓ 点击会话

┌────────────────────┐
│  ← 返回  群聊名称  │  ← AppBar
│                    │
│    ChatPage        │  ← 全屏
│   (消息视图)       │
│                    │
├────────────────────┤
│ [输入框]           │
└────────────────────┘

desktop (≥900px):
┌─────┬──────────────┬──────────────────────┐
│ Nav │  FeedPage    │     ChatPage         │
│ iBar│ (300px)      │  (消息视图)          │
│ 64px│ 会话列表     │                      │
├─────┴──────────────┴──────────────────────┤
│          HeaderBar (窗口控制)              │
└───────────────────────────────────────────┘

tablet (600-899px):
┌──────┬────────────────────────────────────┐
│ Nav  │   FeedPage (可收起)                │
│ iBar │  或 ChatPage (主区域)              │
│ 48px │                                     │
└──────┴────────────────────────────────────┘
```

### 页面级适配方式

```dart
class ImPage extends ConsumerWidget {
  Widget build(context, ref) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return _ImMobileShell();
    return _ImDesktop();
  }
}
```

---

## 桌面端布局 (当前实现)

### IM 主界面

```
┌──────────┬──────────────┬──────────────────────┐
│ NaviBar  │  FeedPage    │     ChatPage         │
│ (导航)   │ (会话列表)   │   (消息视图)         │
│  64px    │   300px      │   填充剩余           │
└──────────┴──────────────┴──────────────────────┘
```

### NaviBar (`widget/navigate_bar.dart`)

64px 垂直侧边栏，包含：

| 图标 | 功能 | 路由 |
|------|------|------|
| 用户头像 | 个人弹窗 (PersonalPopup) | — |
| 🔍 | 全局搜索 | `/search` |
| 主菜单 | MainPopup (多租户切换, 设置, 关于) | — |
| 💬 | 即时通讯 | `/im` |
| 📅 | 日历 | `/calendar` |
| 🎥 | 会议 | `/meeting` |
| 👤 | 通讯录 | `/contact` |
| 📄 | 办公文档 | `/office` |

拖拽：`onPanStart → windowManager.startDragging()` (桌面)

### FeedPage (`page/feed/feed_view.dart`)

- 宽度：300px
- 背景：`surfaceVariant`
- 内容：`ListView` + `ConversationItem`
- 每个条目：头像(36x36) + 名称 + 摘要 + 时间 + 未读角标
- 交互：点击进入聊天、右键菜单 (置顶/已读/删除)
- 状态：高亮当前 `chatId`

### ChatPage (`page/chat/chat_view.dart`)

结构（从上到下）：
1. **ChatHeader** (48px) — 名称、在线状态、搜索按钮、群设置
2. **AnnouncementBanner** — 群公告（可关闭）
3. **PinnedBanner** — 置顶消息 (maxHeight 80)
4. **SearchBar** — 消息内搜索（可选）
5. **MessageView** (Expanded) — `ListView.builder` 消息列表
6. **MessageInput** — Quill 编辑器 + 工具栏

侧面板（桌面 slide-in overlay）：
- `GroupProfile` — 群资料/成员/设置 (300px)
- `ThreadPanel` — 消息评论线程 (320px)

### HeaderBar (`widget/header_bar.dart`)

| 平台 | 内容 |
|------|------|
| macOS | 标题 + 红绿灯按扭（系统自带），26px 高 |
| Windows | 标题 + 自定义 min/max/close 按钮，26px 高 |
| 移动端 | 隐藏（使用系统状态栏） |

---

## 移动端布局方案

### 导航

移动端使用 `BottomNavigationBar`（5 个 tab）：

| Tab | 图标 | 路由 | 说明 |
|-----|------|------|------|
| 消息 | `Icons.message` | `/im` | 会话列表 + 聊天 |
| 日历 | `Icons.calendar_month` | `/calendar` | 日程管理 |
| 会议 | `Icons.video_call` | `/meeting` | 会议列表 + VC |
| 联系人 | `Icons.contact_page` | `/contact` | 组织架构 |
| 办公 | `Icons.description` | `/office` | 协作文档 |

搜索入口移至 FeedList 顶部搜索栏。主菜单功能移至"个人中心"或"更多"。

### IM 导航模式

```
/im (Route)
  ├── mobile (<600px): ImMobilePage
  │   ├── FeedListPage (全屏、带搜索栏)
  │   └── [push] /im/chat/:id → ChatPage (全屏、带返回键)
  │
  ├── tablet (600-899px): ImTabletPage
  │   ├── NaviBar (48px) + Row(FeedPage || ChatPage)
  │   └── FeedPage 可收起（抽屉式）
  │
  └── desktop (≥900px): ImDesktopPage
      └── 现有实现不变
```

FeedList 数据由 `ImController` 单例持有，持续接收 SDK 推送。ChatPage push 打开/返回时，FeedList 状态保留在内存中。

### 交互适配

| 桌面端 | 移动端 |
|--------|--------|
| `MouseRegion` + hover 显示操作按钮 | 长按 `onLongPress` 弹出 ActionSheet |
| `onSecondaryTap` 右键菜单 | `showModalBottomSheet` 底部弹窗 |
| `showMenu(positioned)` 定位弹出 | `showModalBottomSheet` 底部弹窗 |
| 窗口拖拽 (startDragging) | 不支持 |
| 窗口最小化/关闭按钮 | 系统状态栏 |
| 消息多选拖拽 | 长按进入选择模式 |
| `Tooltip` hover | 保留（长按触发） |
| `SelectionArea` | 保留 |

### ContextMenu 抽象

统一交互工具，根据平台分发不同的 UI：

```dart
enum ContextMenuAction { reply, thread, forward, copy, delete, pin }

// 桌面: showMenu (右键坐标)
// 移动: showModalBottomSheet
Future<T?> showContextMenu<T>({
  required BuildContext context,
  required List<ContextMenuAction> actions,
  Offset? position,           // 桌面右键位置
}) {
  if (isDesktop) {
    return showMenu(context: context, position: RelativeRect.fromLTRB(...), items: ...);
  }
  return showModalBottomSheet(context: context, builder: (ctx) => BottomSheetMenu(actions));
}
```

---

## 视频会议 (VC) — 移动端方案

### 架构

桌面端：`desktop_multi_window` 创建独立子窗口
移动端：全屏页面 + 收缩浮窗

### 收缩流程

```
用户点击 "最小化/收缩"
  → VcPage pop (路由出栈)
  → WebRTC 连接保持 (VcLogic 全局单例)
  → OverlayEntry 插入悬浮窗 (40×40 圆形缩略图)
  → 拖拽浮窗至屏幕任意位置

用户点击悬浮窗
  → OverlayEntry 移除
  → 重新 push VcPage，传入 sessionId
  → 恢复会议界面
```

### 关键实现

- `VcLogic` 提升为 Riverpod 全局单例，不在页面销毁时释放
- 浮窗使用 `Overlay.of(context).insert(OverlayEntry(...))`
- 拖拽用 `GestureDetector` + `onPanUpdate`
- WebRTC 在后台继续收发音视频，浮窗显示小头像
- `android` 前台 Service 保活 (Phase 2)

---

## 平台适配器

### 桌面专有包统一处理

| 包 | 桌面 | 移动端 |
|----|------|--------|
| `window_manager` | 窗口控制、拖拽 | 条件 import，调用为空 |
| `desktop_multi_window` | 子窗口 (VC/Webview) | 替换为 in-app 页面 |
| `desktop_lifecycle` | 桌面生命周期 | 不初始化 |
| `screen_capturer` | 桌面截屏 | 不启用 |

### 条件导入模式

```dart
// platform_adapter.dart
export 'platform_stub.dart'
    if (dart.library.io) 'platform_desktop.dart';
```

```dart
abstract class WindowAdapter {
  void startDragging() {}
  Future<void> minimize() async {}
  Future<void> maximize() async {}
  Future<void> close() async {}
  void addListener(WindowListener listener) {}
  void removeListener(WindowListener listener) {}
}
```

---

## 登录页

| 布局 | 设计 |
|------|------|
| 桌面 (≥900px) | 双栏：左侧品牌面板(插图+slogan) + 右侧表单，总宽 720px |
| 移动 (<600px) | 全屏表单，品牌元素简化为顶部 logo + 标语 |

---

## 实现计划

### P0 — 基础设施

| # | 任务 | 涉及文件 |
|---|------|---------|
| 1 | 平台适配器层 (WindowAdapter 抽象+条件导入) | 新建 `widget/platform_adapter.dart` |
| 2 | `isDesktop` / `isMobile` 工具函数 | `utils/platform.dart` |
| 3 | 路由改造: ShellRoute + BottomNavBar | `router/router.dart` |
| 4 | 移动端入口 main.dart 移除桌面包强制初始化 | `main.dart` |
| 5 | app.dart 移除 window_manager 依赖 | `app.dart` |

### P1 — 响应式布局

| # | 任务 | 涉及文件 |
|---|------|---------|
| 6 | `ResponsiveScaffold` 容器 | 新建 |
| 7 | ImPage 响应式分支 (mobile/tablet/desktop) | `page/im/im_view.dart` |
| 8 | `NaviBar` → `BottomNavBar` 移动端 | `widget/bottom_navi_bar.dart` |
| 9 | FeedList 分离为独立路由组件 | `page/feed/` |
| 10 | IM 内路由: FeedList push → Chat | `router/router.dart` |
| 11 | `HeaderBar` 移动端隐藏 | `widget/header_bar.dart` |
| 12 | 登录页移动端布局 | `page/login/login_view.dart` |

### P2 — 移动端交互

| # | 任务 | 涉及文件 |
|---|------|---------|
| 13 | ContextMenu 统一抽象 (桌面 popup / 移动 bottom sheet) | 新建 |
| 14 | `MessageBox` 长按 ActionSheet | `widget/message.dart` |
| 15 | `ConversationItem` 长按菜单 | `widget/feedcard.dart` |
| 16 | 键盘适配 + `viewInsets` 处理 | `widget/message_input.dart` |
| 17 | Android 返回键处理 | `router/router.dart` |
| 18 | 消息列表 Pull-to-refresh / 加载更多 | `page/chat/chat_view.dart` |

### P3 — 会议与完善

| # | 任务 | 涉及文件 |
|---|------|---------|
| 19 | VC 全屏页面 (替代子窗口) | `page/vc/vc_view.dart` |
| 20 | VcLogic 全局单例化 | `page/vc/vc_logic.dart` |
| 21 | 悬浮窗 Overlay 实现 | `page/vc/` |
| 22 | Webview 移动端页面 (替代子窗口) | `webview.dart` |
| 23 | 设置页面移动端适配 | `page/setting/settings_page.dart` |
| 24 | 子页面 (GroupProfile / Thread) 移动端全屏 push | 各子页面 |
| 25 | 截屏功能移动端禁用 | `page/screenshot/` |

---

## 相关文件

| 文件 | 角色 |
|------|------|
| `docs/client.md` | 客户端架构概览 |
| `docs/client_style.md` | 主题设计系统 (BuzzingTheme / ThemeExtension) |
| `docs/client_ui.md` | **本文 — UI 架构与移动端适配方案** |
| `buzzing/lib/router/router.dart` | GoRouter 路由配置 |
| `buzzing/lib/controller/im.dart` | IM 核心状态 |
| `buzzing/lib/event/event_bus.dart` | 事件总线 |
| `buzzing/lib/res/theme.dart` | BuzzingTheme + AppTheme |
