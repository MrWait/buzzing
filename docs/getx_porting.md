# GetX 迁移方案

## 目标技术栈

| 原方案 (GetX) | 目标方案 | 说明 |
|---|---|---|
| `GetMaterialApp` + `getPages` | `MaterialApp.router` + `GoRouter` | 路由 |
| `GetxController` + `.obs` + `Obx` + `GetBuilder` | Riverpod (`Notifier` + `ref.watch`) | 状态管理 |
| `Get.put` / `Get.find` / `Get.lazyPut` | Riverpod `Provider` / `NotifierProvider` | DI |
| `Translations` + `.tr` | `slang` (类型安全代码生成) | 国际化 |
| `EventController` | `StreamController` 事件总线 | 事件 |

## 迁移顺序

```
Phase 0 ──→ Phase 1 ──→ Phase 2 ──→ Phase 3 ──→ Phase 4 ──→ Phase 5
 依赖        DI + State    路由        翻译         事件总线     清理
 安装         30f          10f          8f           1f        重复代码
```

- 每个 Phase 完成 + lint 通过后，`git commit`，再进入下一 Phase
- 每修改一个文件，立即 `flutter analyze` 验证，不累积错误
- Phase 1-3 可并行（不冲突的文件同时改），但建议按顺序避免认知负荷

---

## Phase 0 — 依赖安装

### pubspec.yaml 变更

```yaml
dependencies:
  # ── 移除 ──
  # get: ^4.6.6

  # ── 新增 ──
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  go_router: ^15.1.0
  slang: ^4.5.0
  slang_flutter: ^4.5.0
  platform: ^3.1.0          # 替代 GetPlatform

dev_dependencies:
  riverpod_generator: ^2.6.3
  build_runner: ^2.4.0
  slang_build_runner: ^4.5.0
```

### 目录结构调整

```
lib/
├── provider/                 # NEW — Riverpod providers 集中定义
│   ├── app_provider.dart
│   ├── sdk_provider.dart
│   ├── im_provider.dart
│   └── ...
├── router/                   # NEW — GoRouter 配置
│   ├── router.dart
│   └── routes/
│       ├── splash_route.dart
│       ├── login_route.dart
│       ├── im_route.dart
│       └── ...
├── i18n/                     # NEW — slang 翻译
│   ├── strings.i18n.json     # 翻译源文件
│   └── ...
├── event/                    # NEW — 事件总线
│   └── event_bus.dart
│ controller/                 # DELETE after Phase 1
│ routes/                     # DELETE after Phase 2
│ res/strings.dart            # DELETE after Phase 3
```

---

## Phase 1 — DI + 状态管理 (Riverpod)

### 1.1 核心模式转换

#### GetxController → Riverpod Notifier

**Before** (`controller/im.dart`):
```dart
class ImController extends GetxController {
  final sdk = Get.find<SdkController>();
  final ev = Get.find<EventController>();
  final app = Get.find<AppController>();

  var showMentionPopup = false.obs;
  var avatar = "".obs;
  var chatId = Int64(0).obs;
  var userId = Int64(0);
  var debug = true.obs;
  var entity = Entity.create();

  @override
  void onInit() {
    super.onInit();
    sdk.regPushCallback(Command.PUSH_FEED_LIST.value, onPushFeedList);
    sdk.regPushCallback(Command.PUSH_MESSAGES.value, onPushMessages);
    quillController.addListener(onTextChanged);
  }

  void enterChat(Int64 id) {
    if (chatId != id) {
      messagePosList.clear();
      chatId.call(id);
      preloadMessage(chatId.value, chat.lastMessagePos, 30);
    }
  }

  void updateFeedList() {
    feedList.sort(...);
    update([ConstKey.KeyFeedList]);
  }
}
```

**After** (`provider/im_provider.dart`):
```dart
@immutable
class ImState {
  final bool showMentionPopup;
  final String avatar;
  final Int64 chatId;
  final bool debug;
  final Entity entity;
  final List<FeedModel> feedList;
  final List<MessageIndex> messagePosList;
  final Map<Int64, UserVer> userVers;

  const ImState({
    this.showMentionPopup = false,
    this.avatar = '',
    this.chatId = Int64.ZERO,
    this.debug = true,
    this.entity = Entity.create(),
    this.feedList = const [],
    this.messagePosList = const [],
    this.userVers = const {},
  });

  ImState copyWith({...}) => ImState(...);
}

class ImNotifier extends Notifier<ImState> {
  @override
  ImState build() {
    _initPushHandlers();
    return const ImState();
  }

  void enterChat(Int64 id) {
    if (state.chatId == id) return;
    state = state.copyWith(
      messagePosList: [],
      chatId: id,
    );
    preloadMessage(id, getChat(id)?.lastMessagePos ?? 0, 30);
  }

  void updateFeedList() {
    final sorted = List<FeedModel>.from(state.feedList)..sort(...);
    state = state.copyWith(feedList: sorted);
  }
}

final imProvider = NotifierProvider<ImNotifier, ImState>(ImNotifier.new);

// 依赖注入 — 替代 Get.find<SdkController>()
final sdkProvider = Provider<SdkController>((ref) => SdkController(ref));
```

#### `.obs` 变量 → `State` 字段 + `copyWith`

`.obs` 是 GetX 的核心，Riverpod 中通过在 State 类集中管理：

```dart
// Before
var showMentionPopup = false.obs;
var avatar = "".obs;
var chatId = Int64(0).obs;
var debug = true.obs;

// After — 作为 ImState 的一部分（见上方）
```

#### `Rx<Int64> getUserVer(Int64 id)` → `FamilyProvider`

```dart
// Before
Rx<Int64> getUserVer(Int64 id) {
  if (userVers.containsKey(id)) return userVers[id]!.ver;
  userVers[id] = UserVer(Int64(0), null);
  return userVers[id]!.ver;
}

// After
final userVerProvider = Provider.family<Int64, Int64>((ref, id) {
  final state = ref.watch(imProvider);
  return state.userVers[id]?.ver.value ?? Int64(0);
});
```

### 1.2 Obx → Consumer / ref.watch

**Before** (`page/chat/chat_view.dart`):
```dart
class ChatPage extends StatelessWidget {
  final im = Get.find<ImController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var chatId = im.chatId.value;
      var chat = im.getChat(chatId);
      if (chatId == 0) return ...;
      return Column(...);
    });
  }
}
```

**After**:
```dart
class ChatPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imState = ref.watch(imProvider);
    final chatId = imState.chatId;
    if (chatId == Int64.ZERO) return ...;
    return Column(...);
  }
}
```

### 1.3 GetBuilder + update() → ref.watch + 状态变更

**Before**:
```dart
// View
GetBuilder<ImController>(
  id: ConstKey.KeyChatMessage,
  builder: (c) => ListView(...),
)

// Controller
update([ConstKey.KeyChatMessage]);
```

**After**:
```dart
// View — 用 select 监听特定字段
final messagePosList = ref.watch(
  imProvider.select((s) => s.messagePosList),
);
ListView.builder(itemCount: messagePosList.length, ...);

// Notifier — copyWith 自动触发重建
state = state.copyWith(messagePosList: newList);
```

### 1.4 依赖注入迁移

| GetX 写法 | Riverpod 写法 |
|---|---|
| `Get.put(SdkController())` | `final sdkProvider = Provider<SdkController>(...)` |
| `Get.find<SdkController>()` | `ref.watch(sdkProvider)` |
| `Get.lazyPut(() => LoginLogic())` | `final loginLogicProvider = Provider.autoDispose<LoginLogic>(...)` |
| `Bindings` | `ProviderScope` overrides + `ref` in build |

#### InitBinding 迁移

**Before** (`app.dart`):
```dart
class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(EventController());
    Get.put(SdkController());
    Get.put(ImController());
    Get.put(AppController());
  }
}
```

**After** (`provider/app_provider.dart`):
```dart
final eventBusProvider = Provider<EventBus>((ref) => EventBus());

final sdkProvider = Provider<SdkController>((ref) {
  final bus = ref.watch(eventBusProvider);
  return SdkController(eventBus: bus);
});

final imProvider = NotifierProvider<ImNotifier, ImState>(ImNotifier.new);

final appControllerProvider = NotifierProvider<AppNotifier, AppState>(
  AppNotifier.new,
);
```

### 1.5 无侵入迁移细节

有些文件只使用 `Get.find()` 获取依赖（不涉及 `GetxController`、`.obs`、`Obx`），这些文件可以先在构造函数中直接注入：

```dart
// Before
class ContactController extends GetxController {
  final sdk = Get.find<SdkController>();
}

// After — 简单 widget 内直接传 ref
class ContactPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sdk = ref.watch(sdkProvider);
    ...
  }
}

// After — 需要方法的场景，转为普通 class + Riverpod Provider
class ContactLogic {
  ContactLogic({required this.sdk, required this.im});
  final SdkController sdk;
  final ImNotifier im;
}

final contactLogicProvider = Provider.autoDispose<ContactLogic>((ref) {
  final sdk = ref.watch(sdkProvider);
  final im = ref.watch(imProvider.notifier);
  return ContactLogic(sdk: sdk, im: im);
});
```

### 1.6 AppController 迁移要点

`AppController` 是多功能控制器，拆分为多个独立 Provider：

| 职责 | 目标 |
|---|---|
| `theme` (0.obs) | `themeProvider (StateProvider<int>)` |
| `clientConfigMap` (.obs) | `clientConfigProvider` |
| `runningBackground` | `isBackgroundProvider (StateProvider<bool>)` |
| `windows` / 子窗口管理 | 独立普通 class，通过 provider 注入 |
| `getLocale()` | `localeProvider` |
| 通知管理 | 独立普通 class |
| `backgroundSubject` | `EventBus` 的一部分 |

---

## Phase 2 — 路由 (go_router)

### 2.1 GetMaterialApp → MaterialApp.router

**Before** (`app.dart`):
```dart
GetMaterialApp(
  translations: TranslationService(),
  getPages: AppPages.routes,
  initialBinding: InitBinding(),
  initialRoute: AppRoute.SPLASH,
)
```

**After** (`router/router.dart`):
```dart
final routerProvider = Provider<GoRouter>((ref) {
  final locale = ref.watch(localeProvider);
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (ctx, state) => SplashPage()),
      GoRoute(path: '/login', builder: (ctx, state) => LoginPage()),
      ShellRoute(
        builder: (ctx, state, child) => ImShell(child: child),
        routes: [
          GoRoute(path: '/im', builder: (ctx, state) => ImPage()),
          GoRoute(path: '/contact', builder: (ctx, state) => ContactPage()),
          GoRoute(path: '/calendar', builder: (ctx, state) => CalendarPage()),
          GoRoute(path: '/meeting', builder: (ctx, state) => MeetingPage()),
        ],
      ),
    ],
  );
});
```

**After** (`app.dart`):
```dart
MaterialApp.router(
  routerConfig: ref.watch(routerProvider),
  locale: locale,
  localizationsDelegates: [...],
  supportedLocales: [...],
)
```

> ShellRoute 用于 IM/Contact/Calendar/Meeting 共用的底部/左侧导航栏，替代 GetPage 的 `transition: Transition.noTransition`。

### 2.2 导航调用迁移

**Before** (`routes/app_navigator.dart`):
```dart
class AppNavigator {
  static void backLogin() {
    Get.until((route) => Get.currentRoute == AppRoute.LOGIN);
  }
  static void startLogin() {
    Get.offAllNamed(AppRoute.LOGIN);
  }
  static void startIm(LoginUser? user) { ... Get.offAllNamed(AppRoute.IM); }
  static void startRegister(String way) {
    Get.toNamed(AppRoute.REGISTER, arguments: {'registerWay': way});
  }
}
```

**After** (`router/navigator.dart`):
```dart
class AppNavigator {
  static void backLogin(BuildContext context) {
    context.go('/login');
  }
  static void startLogin(BuildContext context) {
    context.go('/login', extra: true); // extra: replaceAll
  }
  static void startIm(BuildContext context, LoginUser? user) async {
    // 原有 SDK init 逻辑
    context.go('/im');
  }
  static void startRegister(BuildContext context, String way) {
    context.push('/register', extra: {'registerWay': way});
  }
}
```

| GetX 方法 | go_router 方法 |
|---|---|
| `Get.toNamed(path, arguments)` | `context.push(path, extra: arguments)` |
| `Get.offAllNamed(path)` | `context.go(path)` |
| `Get.back()` | `context.pop()` |
| `Get.until(predicate)` | `context.go(targetPath)` |
| `Get.arguments` | `GoRouterState.of(context).extra` |

> `routes/app_navigator.dart` 的方法签名需要增加 `BuildContext context` 参数，或通过 `ref` 获取 GoRouter 实例。

### 2.3 无路由页面（弹窗/Dialog/BottomSheet）

**Before**:
```dart
Get.back();                 // 关闭
Get.snackbar(title, msg);  // SnackBar
Get.defaultDialog(...);     // Dialog
Get.bottomSheet(...);       // BottomSheet
```

**After**:
```dart
// Snackbar
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

// Dialog
showDialog(context: context, builder: (ctx) => AlertDialog(...));

// BottomSheet
showModalBottomSheet(context: context, builder: (ctx) => ...);

// 返回
Navigator.of(context).pop();
```

### 2.4 AppRoute 常量 → 保持常量

`app_routes.dart` 中的路径常量可保留，去掉 `part of` 即可：

```dart
abstract class AppRoute {
  static const splash = '/splash';
  static const login = '/login';
  static const im = '/im';
  static const contact = '/contact';
  static const calendar = '/calendar';
  static const meeting = '/meeting';
  ...
}
```

### 2.5 NoTransitions → go_router 自定义过渡

**Before**:
```dart
class NoTransitions extends PageTransitionsTheme {
  @override
  Widget buildTransitions(...) {
    if (GetPlatform.isDesktop) return child;
    return super.buildTransitions(...);
  }
}
```

**After**:
```dart
final _customTransition = CustomTransitionPage<void>(
  transitionDuration: Duration.zero,
  reverseTransitionDuration: Duration.zero,
  transitionsBuilder: (ctx, anim, secAnim, child) => child,
);

// 在 GoRoute 中为桌面端设置:
GoRoute(
  path: '/im',
  pageBuilder: (ctx, state) => _customTransition.copyWith(child: ImPage()),
)
```

> 或使用 `GoRouter` 的 `pageBuilder` 参数全局控制。

### 2.6 Get.currentRoute 替代

```dart
// Before
if (Get.currentRoute == AppRoute.LOGIN) { ... }

// After
final router = GoRouter.of(context);
if (router.location == '/login') { ... }
```

---

## Phase 3 — 国际化 (slang)

### 3.1 翻译源文件

将 `lib/res/localization/en_US.dart` 和 `zh_CN.dart` 合并为 JSON 文件：

```json
// lib/i18n/strings.i18n.json
{
  "$schema": "https://raw.githubusercontent.com/nicholasgasior/slang/main/schema.json",
  "locale": "zh",
  "translations": {
    "goBack": "返回",
    "ok": "确定",
    "home": "首页",
    "login": "登录",
    "cancel": "取消",
    "send": "发送",
    // ... 全部 300+ 条目
  }
}
```

```json
// lib/i18n/strings_en.i18n.json
{
  "$schema": "https://raw.githubusercontent.com/nicholasgasior/slang/main/schema.json",
  "locale": "en",
  "translations": {
    "goBack": "Back",
    "ok": "OK",
    "home": "Home",
    "login": "Log In",
    "cancel": "Cancel",
    "send": "Send",
    // ...
  }
}
```

### 3.2 自动生成

```bash
flutter pub run build_runner build
```

生成 `lib/i18n/strings.g.dart`，包含：

```dart
// 类型安全的翻译类
class Translations {
  String get goBack;
  String get ok;
  String get home;
  String get login;
  String get cancel;
  String get send;
  // ...
}

// Flutter 集成
class AppLocaleProvider extends FlutterLocaleProvider {
  @override
  Future<Translations> load(Locale locale) => Translations.load(locale);
}
```

### 3.3 `.tr` → `t.key`

**Before**:
```dart
static get goBack => 'goBack'.tr;
Text(StrRes.goBack)
```

**After**:
```dart
// v: 当前 Translations 实例
Text(v.goBack)
```

### 3.4 获取 Locale

**Before**:
```dart
Get.deviceLocale         // 设备默认locale
Get.locale               // 当前locale
localeResolutionCallback: (locale, list) { Get.locale ??= locale; }
```

**After**:
```dart
// WidgetsBinding 获取设备 locale
WidgetsBinding.instance.platformDispatcher.locale;

// Riverpod 管理当前locale
final localeProvider = StateProvider<Locale>((ref) {
  return WidgetsBinding.instance.platformDispatcher.locale;
});

// MaterialApp.router 配置
MaterialApp.router(
  locale: ref.watch(localeProvider),
  supportedLocales: [Locale('zh', 'CN'), Locale('en', 'US')],
)
```

### 3.5 locale 切换

**Before** (`app_controller.dart`):
```dart
Locale? getLocale() {
  var local = Get.locale;
  var index = DataPersistence.getLanguage() ?? 0;
  switch (index) {
    case 1: local = Locale('zh', 'CN'); break;
    case 2: local = Locale('en', 'US'); break;
  }
  return local;
}
```

**After** (`provider/app_provider.dart`):
```dart
final languageIndexProvider = StateProvider<int>((ref) {
  return DataPersistence.getLanguage() ?? 0;
});

final localeProvider = Provider<Locale>((ref) {
  final index = ref.watch(languageIndexProvider);
  switch (index) {
    case 1: return Locale('zh', 'CN');
    case 2: return Locale('en', 'US');
    default: return WidgetsBinding.instance.platformDispatcher.locale;
  }
});
```

### 3.6 StrRes → 保留引用层

在迁移期间，`StrRes` 可以保留为封装层，内部改为调用 slang：

```dart
class StrRes {
  static Translations? _t;
  static Translations get t => _t!;

  static String get goBack => t.goBack;
  static String get ok => t.ok;
  // ...
}
```

迁移完成后，逐步将所有 `StrRes.xxx` 改为直接使用 `t.xxx`，最后删除 `StrRes`。

---

## Phase 4 — 事件总线

### 4.1 EventController 替代

**Before** (`controller/event.dart`):
```dart
class EventController extends GetxController {
  var eventHandler = Map<int, Map<String, Function>>();

  void regEventHandler(int event, String tag, Function f) { ... }
  void removeEventHandler(int event, String tag) { ... }
  void emitEvent(int event) { ... }
}
```

**After** (`event/event_bus.dart`):
```dart
enum GlobalEvent { logined, messageUpdate, feedlistUpdate }

class EventBus {
  final _controller = StreamController<GlobalEvent>.broadcast();
  Stream<GlobalEvent> get stream => _controller.stream;

  void emit(GlobalEvent event) => _controller.add(event);
  void dispose() => _controller.close();
}

final eventBusProvider = Provider<EventBus>((ref) => EventBus());
```

### 4.2 注册/监听

```dart
// Before
ev.regEventHandler(GlobalEvent.Logined.num, "im_controller", () {
  fetchFeed();
});

// After
ref.listen(eventBusProvider.stream, (prev, event) {
  if (event == GlobalEvent.logined) fetchFeed();
});

// 或
ref.watch(eventBusProvider.stream.where((e) => e == GlobalEvent.logined));
```

### 4.3 发送事件

```dart
// Before
ev.emitEvent(GlobalEvent.Logined.num);

// After
ref.read(eventBusProvider).emit(GlobalEvent.logined);
```

---

## Phase 5 — 杂项替换

### 5.1 GetPlatform

| GetX 方法 | 替代 |
|---|---|
| `GetPlatform.isDesktop` | `Platform.isMacOS \|\| Platform.isWindows \|\| Platform.isLinux` |
| `GetPlatform.isWindows` | `Platform.isWindows` |

```dart
import 'dart:io' show Platform;
// 或
import 'package:platform/platform.dart';
```

### 5.2 GetUtils

| GetX 方法 | 替代 |
|---|---|
| `GetUtils.isEmail(text)` | `RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(text)` |

### 5.3 Get.context

```dart
// Before
showDialog(context: Get.context!, builder: ...);

// After
// 在 widget 树中有 BuildContext 的地方直接使用:
final ctx = context;
// 或在 StatelessWidget 中无法获取时，使用 NavigatorKey
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
MaterialApp.router(
  navigatorKey: _navigatorKey,
  ...
);
// 然后在任意位置:
_navigatorKey.currentContext!. ...
```

### 5.4 调试日志

```dart
// Before
GetMaterialApp(enableLog: true, logWriterCallback: printLog);

// After — 无需 GetX 配置，直接使用现有 Logger
```

### 5.5 Desktop 无过渡动画

**Before** (`app.dart` `NoTransitions`):
```dart
if (GetPlatform.isDesktop) return child;
```

**After** — go_router 的 pageBuilder 全局配置：
```dart
GoRouter(
  routes: [...],
  // 自定义过渡时长，桌面端为 0
  transitionDuration: const Duration(milliseconds: 0),
  reverseTransitionDuration: const Duration(milliseconds: 0),
)
```

---

## 各文件修改清单

### Phase 1 — DI + 状态 (~30 文件)

| 文件 | 改法 |
|---|---|
| `lib/controller/sdk_controller.dart` | 去掉 `GetxController` 继承，改为普通 class；构造函数注入 `EventBus` |
| `lib/controller/im.dart` | 拆分为 `ImState` + `ImNotifier` + `imProvider` |
| `lib/controller/app_controller.dart` | 拆分为多个 Provider |
| `lib/controller/event.dart` | 整个替换为 `EventBus` |
| `lib/page/*/*_logic.dart` (4个) | 改为普通 class + Provider |
| `lib/page/*/*_binding.dart` (8个) | 删除（Provider 自动管理生命周期） |
| `lib/page/*/*_view.dart` (8个) | `GetxController` → `ConsumerWidget`, `Obx` → `ref.watch` |
| `lib/widget/*.dart` (15+) | 同上 |

### Phase 2 — 路由 (~10 文件)

| 文件 | 改法 |
|---|---|
| `lib/app.dart` | `GetMaterialApp` → `MaterialApp.router` |
| `lib/widget/app_view.dart` | 去掉 `GetBuilder<AppController>` |
| `lib/routes/app_pages.dart` | 删除，替换为 `router/router.dart` |
| `lib/routes/app_routes.dart` | 保留路径常量 |
| `lib/routes/app_navigator.dart` | 方法签名加 `BuildContext` 或 `WidgetRef` |
| `lib/widget/app_view.dart` | 改为 ConsumerWidget |

### Phase 3 — 翻译 (~8 文件)

| 文件 | 改法 |
|---|---|
| `lib/res/strings.dart` | 改为 slang `StrRes` 封装层 |
| `lib/res/localization/en_US.dart` | 导出为 JSON → `strings_en.i18n.json` |
| `lib/res/localization/zh_CN.dart` | 导出为 JSON → `strings.i18n.json` |
| 所有使用 `StrRes.xxx` 的文件 | 逐步改为 `t.xxx` |

### Phase 4 — 事件总线 (1 文件)

| 文件 | 改法 |
|---|---|
| `lib/controller/event.dart` | 替换为 `lib/event/event_bus.dart` |

### Phase 5 — 杂项 (~10 文件)

| 文件 | 改法 |
|---|---|
| `lib/utils/http_util.dart` | `code.toString().tr` → `t.someKey` |
| 所有 `import 'package:get/get.dart'` | 替换为具体替代包 |

---

## 风险与注意事项

1. **`SdkController`** 是核心依赖，被大量文件引用。迁移时优先将其改为非 GetX 的普通 class，用 Provider 注入
2. **`ImController`** 是最大最复杂的 Controller（~600 行），建议拆分：状态放 `ImState`，业务逻辑放 `ImNotifier`，纯 UI 逻辑放 widget
3. **`Channel`** 类（`package:channel`）由 SdkController 使用，与 GetX 无关，保持不变
4. **子窗口**（`vc.dart`、`webview.dart`）的 `main()` 入口不使用 GetX，无需迁移
5. **测试**：`sdk_test/` 使用 RustLib 但不依赖 GetX，无需改动；`Get.test` 相关测试需迁移
6. **确保每一步 `git commit` + `flutter analyze` 通过**，避免大面积出错难以回滚
