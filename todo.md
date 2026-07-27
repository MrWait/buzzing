# Flutter 客户端安卓适配 — 实现计划

## P0 — 基础设施

| # | 任务 | 涉及文件 | 说明 |
|---|------|---------|------|
| 1 | 平台适配器层 | `widget/platform_adapter.dart` | WindowAdapter 抽象 + 条件导入，4 个桌面包统一处理 |
| 2 | `isDesktop` / `isMobile` 工具函数 | `utils/platform.dart` | 统一平台判断，替代各处 `Platform.isXxx` |
| 3 | 路由改造: ShellRoute + BottomNavBar | `router/router.dart` | GoRouter 嵌套 ShellRoute，移动端底部 5 tab 导航 |
| 4 | main.dart 移除桌面包强制初始化 | `main.dart` | window_manager/desktop_multi_window/desktop_lifecycle 按需初始化 |
| 5 | app.dart 移除 window_manager 依赖 | `app.dart` | WindowListener 条件接入 |

## P1 — 响应式布局

| # | 任务 | 涉及文件 | 说明 |
|---|------|---------|------|
| 6 | ImPage 响应式分支 | `page/im/im_view.dart` | width < 600: mobile / 600-899: tablet / ≥900: desktop |
| 7 | BottomNavBar 移动端导航 | `widget/bottom_navi_bar.dart` | 5 tab: 消息/日历/会议/联系人/办公 |
| 8 | IM 内路由: FeedList push → Chat | `router/router.dart` + `page/chat/` | 移动端 `/im/chat/:id` 全屏 push，桌面端保持并列 |
| 9 | NaviBar 移动端替换 | `widget/navigate_bar.dart` | 桌面保留，移动端隐藏 (BottomNavBar 替代) |
| 10 | HeaderBar 移动端隐藏 | `widget/header_bar.dart` | 桌面保留，移动端隐藏 (系统状态栏) |
| 11 | 登录页移动端布局 | `page/login/login_view.dart` | 双栏 → 全屏表单，logo 简化为图标+标语 |
| 12 | 各子页面移动端全屏 push | GroupProfile / ThreadPanel etc. | slide-in overlay → 全屏 push |

## P2 — 移动端交互

| # | 任务 | 涉及文件 | 说明 |
|---|------|---------|------|
| 13 | ContextMenu 统一抽象 | 新建 | 桌面 showMenu (右键) / 移动 showModalBottomSheet (长按) |
| 14 | MessageBox 长按 ActionSheet | `widget/message.dart` | 替换 Desktop 右键/hover 操作 |
| 15 | ConversationItem 长按菜单 | `widget/feedcard.dart` | 右键 → 长按 |
| 16 | 键盘适配 + viewInsets | `widget/message_input.dart` | Quill 编辑器键盘弹出处理 |
| 17 | Android 返回键处理 | `router/router.dart` | PopRoute 拦截 / WillPopScope |
| 18 | 消息列表 Pull-to-refresh | `page/chat/chat_view.dart` | 下拉加载历史消息 |

## P3 — 会议与完善

| # | 任务 | 涉及文件 | 说明 |
|---|------|---------|------|
| 19 | VcLogic 全局单例化 | VC 模块 | 页面 pop 时不释放 WebRTC 连接 |
| 20 | VC 全屏页面 (替代子窗口) | `page/vc/vc_view.dart` | 移动端使用路由 push，桌面保持子窗口 |
| 21 | 悬浮窗 Overlay 实现 | `page/vc/` | VC 收缩后 40×40 拖拽浮窗 |
| 22 | Webview 移动端页面 | `webview.dart` | 替代 desktop_multi_window 子窗口 |
| 23 | 设置页面移动端适配 | `page/setting/settings_page.dart` | 移动端布局调整 |
| 24 | 截屏功能移动端禁用 | `page/screenshot/` | 条件不启用 |
