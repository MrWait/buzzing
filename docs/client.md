# Flutter 客户端

## 概述

Flutter 桌面端应用 (支持 Windows/macOS/Linux)，通过 `flutter_rust_bridge` 调用 Rust SDK。

## 目录结构

```
buzzing/lib/
├── main.dart              # 入口 (多窗口支持)
├── app.dart               # BuzzingApp 根组件
├── controller/
│   ├── sdk_controller.dart    # FFI 桥接封装
│   ├── im.dart                # IM 状态管理
│   ├── event.dart             # 全局事件总线
│   └── app_controller.dart    # 应用生命周期
├── models/
│   ├── idl/                   # Dart Protobuf 生成代码
│   ├── model.dart             # Feed 模型构建
│   └── const.dart             # 常量 Key
├── page/
│   ├── splash/                # 启动页
│   ├── login/                 # 登录
│   ├── im/                    # 主界面 (导航+Feed+聊天)
│   ├── feed/                  # 会话列表
│   ├── chat/                  # 消息视图
│   ├── contact/               # 通讯录
│   ├── calendar/              # 日历
│   ├── meeting/               # 会议/音视频
│   └── screenshot/            # 截图 (多窗口桌面)
├── widget/                    # 33 个可复用组件
├── routes/                    # GoRouter 路由
├── res/                       # 资源 (字符串、主题、图片)
└── utils/                     # 工具类
```

## 状态管理 (Riverpod)

### SdkController (`controller/sdk_controller.dart`)
- FFI 生命周期管理 (init/login/logout)
- `invokeAsync()` — 异步请求-响应匹配
- `handlePush()` — 处理服务端推送
- 内部使用 `Channel` 模式：序列号匹配请求与响应

### ImController (`controller/im.dart`)
- `feedList` — 会话列表 (Reactive)
- `messagePosList` — 消息位置列表
- `currentChatId` — 当前聊天 ID
- `userCache` — 用户缓存 Map
- 方法：`onSendMessage()`, `onLoadMore()`, `onPushMessages()`

### EventController (`controller/event.dart`)
- `regEventHandler(key, callback)` — 注册事件
- `emitEvent(key, data)` — 触发事件
- 全局事件总线模式

### AppController (`controller/app_controller.dart`)
- 主题切换
- 本地通知
- 应用徽章
- 国际化

## 路由

| 路由 | 页面 | 绑定 |
|------|------|------|
| `/splash` | SplashPage | SplashBinding |
| `/login` | LoginPage | LoginBinding |
| `/im` | ImPage | ImBinding |
| `/contact` | ContactPage | ContactBinding |
| `/calendar` | CalendarPage | CalendarBinding |
| `/meeting` | MeetingPage | MeetingBinding |

## 页面说明

### Splash
- 初始化 SDK
- 自动登录或跳转登录页

### Login
- 手机号 + 密码登录
- 多租户选择 (一个账号可属于多个组织)

### IM (主界面)
桌面三栏布局：
```
┌──────────┬────────────┬──────────────────┐
│ NaviBar  │  FeedPage  │    ChatPage      │
│ (导航)   │ (会话列表)  │ (消息视图)       │
└──────────┴────────────┴──────────────────┘
```

### Feed
- 会话列表 (带徽标、免打扰、置顶)
- 活跃状态指示

### Chat
- 消息气泡 (文字)
- 滚动到底部
- 加载更多历史消息

### Calendar
支持多视图：月视图、周视图、日视图、计划视图

### Meeting
基于 WebRTC 的音视频通话 (flutter_webrtc)

## 响应式 UI

使用 Riverpod 的 `Notifier` + `ref.watch` 实现精细更新：
- `ConstKey.KeyFeedList` — Feed 列表刷新
- `ConstKey.KeyChatMessage` — 消息列表刷新
- `ConstKey.KeyBadge` — 徽标刷新
