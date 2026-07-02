# 客户端启动流程

## 概述

Flutter 客户端启动后经历 5 个阶段：

```
main() → Config.init() → runApp(BuzzingApp) → /splash → [自动登录] 或 [手动登录] → /im
```

---

## 1. 加载并初始化 SDK

### 入口

`lib/main.dart:86` — `Config.init()` 完成预初始化后调用 `runApp`，`BuzzingApp` 的 Provider 树中 `sdkProvider`（`lib/provider/sdk_provider.dart:3`）创建 `SdkController`。

### SdkController 构造

`lib/controller/sdk_controller.dart:31-41` — 构造函数中通过 `Future.delayed(0)` 异步调用 `_init()`。

### _init() 流程

`lib/controller/sdk_controller.dart:95-128`

1. 构造 `InitRequest` protobuf：
   - `appId = "buzzing"`, `appVersion = "0.1.0"`
   - `env = EnvChannel.ENV_DEV`, `locale = "zh"`
   - `logPath`, `storagePath`, `commonDataPath` 基于 `getApplicationDocumentsDirectory()`
   - `deviceModel = "Windows"`, `deviceId = "123456"`, `isRelease = false`

2. 调用 `RustLib.init()` 初始化 flutter_rust_bridge FFI 层

3. 通过 FFI 调用 Rust SDK：
   ```
   buzzingInit(param: init.writeToBuffer().toList())
   ```
   对应 Rust 侧 `crate::api::flutter::buzzing_init()`，内部初始化日志、存储、网络层。

4. 注册两个事件流处理器：
   - `initSdkPushHandler()` — 接收服务端推送
   - `initSdkInvokeHandler()` — 接收异步 invoke 响应（按 seq 匹配 Completer）

---

## 2. 下载并解析 Client Config

### 触发时机

`lib/page/splash/splash_logic.dart:18` — `SplashLogic.init()` 检查是否有已保存的账号。

### 无已保存账号时的流程

路由跳转到 `/login`，`lib/page/login/login_logic.dart:237` — `LoginLogic.initData()` 加载已保存的 union server 列表，尝试恢复上次使用的 union。

### 连接服务器

`lib/page/login/login_logic.dart:184-213` — `_connectToServer()`：

1. 检查 `DataPersistence.getUnion(server)` 是否有缓存
2. 未缓存时通过 HTTP GET `{scheme}://{host}:{port}/config/client` 拉取配置
3. 解析 `UnionConfig`，包含：
   - `union` — 当前服务器标识
   - `apiPrefix`, `gatewayUrl`, `wsUrl` — 通信端点
   - `uploadFileUrl`, `uploadAvatarUrl`, `uploadFileUrl2` — 上传地址
   - `turnUrl`, `turnUser`, `turnCredential` — TURN 配置
   - `rtcUrl` — WebRTC 信令地址
   - `calendarUrl` — 日历服务地址
   - `platform`, `officeUrl`, `tracing` 等
4. 通过 `DataPersistence.putUnion()`, `addUnionToList()`, `putCurrentUnionServer()` 缓存

### 关键文件

| 文件 | 作用 |
|------|------|
| `lib/utils/config/config.dart:34-54` | `Config.init()` 预初始化 |
| `lib/provider/sdk_provider.dart:1-9` | `sdkProvider` 定义 |
| `lib/controller/sdk_controller.dart:31-128` | `SdkController` 构造 + `_init()` |
| `lib/utils/net/apis.dart` | `Apis.syncConfig()` HTTP 请求 |
| `lib/page/login/login_logic.dart:184-213` | `_connectToServer()` union 配置下载 |
| `lib/models/model.dart` | `Union` / `UnionConfig` 模型定义 |

---

## 3. 手机号密码登录 + 选择身份

### 登录表单

`lib/page/login/login_view.dart:71` — `loginMode == 1` 时显示 `_FormPanel`：
- 手机号/邮箱输入框
- 密码输入框
- 登录按钮

### 登录请求

`lib/page/login/login_logic.dart:110-125` — `_login()`：

```
POST {Config.apiUrl()}/api/accounts/login
Body: { phone, password }
```

返回 `Account` protobuf，包含 `repeated LoginUser users`（每个 `LoginUser` 包含 `User user`、`Tenant tenant`、`token`、`tokenExpire`）。

### 保存账号

```dart
loginAccount.server = Config.union.config.union;
DataPersistence.putAccount(loginAccount);
```

`lib/utils/data_persistence.dart` — 通过 `SpUtil`（SharedPreferences 封装）存储：
- 键 `'account'` — JSON 序列化的 `LoginAccount`（含 account、loginUser、server）

### 身份选择

`lib/page/login/login_logic.dart:125` — `loginMode = 2` 切换到 `_TenantPanel`。

`lib/page/login/login_view.dart:423-486` — `_TenantPanel` 遍历 `loginAccount.account.users`，渲染每个用户的租户信息（名称、头像），用户点击其一。

---

## 4. 保存 Client Config、User Info、Token

### 登录成功后持久化的数据

| 数据 | 存储方式 | Key |
|------|----------|-----|
| Union 配置 | `SpUtil` JSON | `UNION_SERVER_{server}` |
| 当前 union 地址 | `SpUtil` String | `currentUnionServer` |
| union 列表 | `SpUtil` JSON List | `unionServerList` |
| Account (含 token) | `SpUtil` JSON | `account` |
| 设备 ID | `SpUtil` String | `deviceID` |
| 语言偏好 | `SpUtil` Int | `language` |

### LoginAccount 结构

`lib/models/login_certificate.dart:9-51`：

```
LoginAccount
├── account: Account (protobuf)
│   └── users: List<LoginUser>
│       ├── user: User (id, name, avatar, deptId ...)
│       ├── tenant: Tenant (id, name, avatar ...)
│       ├── token: String
│       └── tokenExpire: Int64
├── loginUser: LoginUser (选中的身份)
└── server: String (所属 union server)
```

---

## 5. SDK Login + 进入主界面

### 身份确认后

`lib/page/login/login_logic.dart:259-268` — `loginUser()`：

1. 保存最终选中的身份：
   ```dart
   loginAccount!.loginUser = user;
   DataPersistence.putAccount(loginAccount!);
   ```

2. 调用 SDK 登录：
   ```dart
   sdk.login(
     uid: user.user.id,
     tenantId: user.user.tenantId,
     token: user.token,
     unionClientConfig: json.encode(Config.union.config.toJson()),
   );
   ```

### SdkController.login()

`lib/controller/sdk_controller.dart:158-175`：

1. 构造 `SdkLoginUserRequest` protobuf（userId、tenantId、accessToken、unionClientConfig）
2. 通过 `invokeAsync(Command.USER_LOGIN.value, req.writeToBuffer())` 发送
3. 成功后设置 `userId`，发射 `GlobalEvent.logined` 事件
4. `ImController` 收到事件后调用 `fetchFeed()` 拉取会话列表

### 页面跳转

```dart
AppNavigator.startIm(router, user);  // router.go(AppRoute.IM)
```

### 自动登录流程（Splash 阶段）

`lib/page/splash/splash_logic.dart:30-90` — `try_login()` 在无手动登录时自动执行：
1. 加载已保存的 union 和 account
2. 校验 token 是否过期
3. 有效则调用 `sdk.login()` + 直接进入 `/im`
4. 无效/不存在则延时跳转到 `/login`

### ImController 初始化

`lib/provider/im_provider.dart:8-19` — `imProvider` 创建 `ImController`：
- 从 `DataPersistence.getAccount()` 恢复 `loginUser`
- 设置 `userId`、`avatar`
- 调用 `setUserId()` 通过 SDK 拉取用户信息（`USER_GET_BY_IDS`）

---

## 完整时序图

```
main()
  │
  ├─ Config.init()
  │   ├─ WidgetsFlutterBinding.ensureInitialized()
  │   ├─ SpUtil.getInstance()
  │   ├─ HttpUtil.init()              // Dio + 拦截器
  │   └─ windowManager.show()
  │
  ├─ runApp(BuzzingApp)
  │   ├─ ProviderScope
  │   │   ├─ sdkProvider → SdkController._init()
  │   │   │   ├─ InitRequest protobuf
  │   │   │   ├─ RustLib.init()
  │   │   │   ├─ buzzingInit(InitRequest)
  │   │   │   └─ initSdkPushHandler() / initSdkInvokeHandler()
  │   │   └─ routerProvider → GoRouter(initial: /splash)
  │   └─ MaterialApp.router
  │
  ├─ /splash → SplashPage
  │   └─ try_login()
  │       ├─ [有缓存] → sdk.login() → /im
  │       └─ [无缓存] → /login
  │
  ├─ /login → LoginPage
  │   ├─ loginMode=1: _FormPanel
  │   │   ├─ 选择/输入 union server
  │   │   │   └─ _connectToServer() → GET /config/client → 缓存 union
  │   │   └─ 手机号 + 密码 → POST /api/accounts/login
  │   │       ├─ DataPersistence.putAccount()
  │   │       └─ loginMode=2
  │   │
  │   └─ loginMode=2: _TenantPanel
  │       └─ 选择身份 →
  │           ├─ DataPersistence.putAccount(loginUser)
  │           ├─ sdk.login(USER_LOGIN)
  │           │   ├─ invokeAsync → Rust → 服务端
  │           │   └─ emit(GlobalEvent.logined)
  │           │       └─ ImController.fetchFeed()
  │           └─ router.go(/im)
  │
  └─ /im → ImPage
      ├─ NaviBar
      ├─ FeedPage (会话列表)
      └─ ChatPage (聊天面板)
```

---

## 关键文件索引

| 阶段 | 文件 | 关键行 |
|------|------|--------|
| SDK Init | `lib/controller/sdk_controller.dart` | 95-128 `_init()` |
| SDK Init | `lib/provider/sdk_provider.dart` | 1-9 `sdkProvider` |
| Config 下载 | `lib/page/login/login_logic.dart` | 184-213 `_connectToServer()` |
| Config 下载 | `lib/utils/net/apis.dart` | `Apis.syncConfig()` |
| 手机登录 | `lib/page/login/login_logic.dart` | 110-125 `_login()` |
| 身份选择 | `lib/page/login/login_view.dart` | 423-486 `_TenantPanel` |
| 持久化 | `lib/utils/data_persistence.dart` | `putAccount()` / `putUnion()` |
| 账号模型 | `lib/models/login_certificate.dart` | 9-51 `LoginAccount` |
| SDK login | `lib/controller/sdk_controller.dart` | 158-175 `login()` |
| 自动登录 | `lib/page/splash/splash_logic.dart` | 30-90 `try_login()` |
| 路由跳转 | `lib/routes/app_navigator.dart` | 21-23 `startIm()` |
| IM 初始化 | `lib/provider/im_provider.dart` | 8-19 `imProvider` |
| Union 配置 | `lib/models/model.dart` | `Union` / `UnionConfig` |
