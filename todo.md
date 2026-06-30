# 日历模块性能优化清单

## 优先级说明

| 标记 | 含义 |
|------|------|
| 🔴 P0 | 上线前必须修复，否则性能不可接受 |
| 🟠 P1 | 预计成为瓶颈，应在上线前/后一周内优化 |
| 🟡 P2 | 可上线后按需优化 |
| 🔵 P3 | 低优先级，可推迟 |

---

## P0

| # | 问题 | 方案 | 状态 |
|---|------|------|------|
| 1 | **`notify_time` 在 Extra BLOB 中** — 提醒扫描无法用 SQL 索引过滤 `notify_time`，需全表读取 schedules 后再反序列化 Extra 列 | **已设计：** `schedule_reminders` 专表 + BatchWorker（每小时）+ RemindWorker（每 30 秒）；提醒扫描 `remind_at` 索引范围查询，不碰 Extra 列 | ✅ 已设计 |
| 2 | ~~**`schedule_pull_by_calendar_ids` 实时展开 cycled** — 每次客户端请求都实时计算展开，CPU 浪费严重~~ | **已解决：** 按需展开方案，查询直接走 schedules 表；仅 `expand_end` 不足时触发一次展开 | ✅ 已设计 |

## P1

| # | 问题 | 方案 | 状态 |
|---|------|------|------|
| 3 | **`schedule_update` modify_scope=1 全量 DELETE+REINSERT** — 用户频繁编辑（如改颜色反复点保存）触发每次 ~120 条 DELETE+INSERT | **已设计：** 检测 time_changed（start_time/end_time/cycle 变化时重建），否则走 `update_by_cycle_rule_id` 原地 UPDATE metadata 字段 | ✅ 已设计 |
| 4 | **`reminder_logs` 逐条 INSERT + 无清理** — 每个 `(schedule_id, user_id, notify_minute)` 分开执行 SELECT+INSERT；表只增不删无限膨胀 | **已解决：** `reminder_logs` 替换为 `schedule_reminders` + `batch_insert_ignore` + 每小时 `cleanup_orphans` | ✅ 已设计 |

## P2

| # | 问题 | 方案 | 状态 |
|---|------|------|------|
| 5 | **`schedule_expand_range` 每次展开创建新 HashSet + id_gen** — `week_seqs` 和 `exception_times` 每次调用都重建 HashSet；每次实例都调 `id_gen`（含 DB 写入） | `id_gen` 为纯内存操作，非 DB 写入；HashSet ≤7 元素重建可忽略；最坏 400 次调用 ~几十微秒。非瓶颈 | ❌ 不需要 |
| 6 | **`calendar_search` 无索引无分页** — `LIKE '%keyword%'` 全表扫描，无 LIMIT | **已设计：** GIN trgm 索引 + `limit/offset` 分页参数 | ✅ 已设计 |
| 7 | **`calendar_update` subscribers JSON 全量写** — 修改个人颜色重写全部订阅者数据 | **已设计：** `user2_calendars` 改为标准多对多表（每订阅一行），`calendar.subscriber` JSON 废弃，CACHE_CALENDAR 改从 `user2_calendars` 加载 | ✅ 已设计 |

## P3

| # | 问题 | 方案 | 状态 |
|---|------|------|------|
| 8 | **`CACHE_CALENDAR` 读写锁竞争** — `write().await` 阻塞所有读 | 用 RwLock 写时 copy-on-write 或改用 moka 的细粒度失效 | ❌ 待观察 |
| 9 | **空扫描周期浪费** — 凌晨无日程时仍每 30s 执行 SQL | 已由 `schedule_reminders` 专表 + 部分索引消除，空窗口只需 B-tree seek | ❌ 不需要 |
| 10 | **cycled 展开无结束日期时的最大实例限制** — 400 限制在极端高频场景（每秒 1 次）仍可能产生大量实例 | 按需展开天然限制窗口（初始 120 天，增量仅查询范围），最小步长 1 天；400 安全网不会被触及 | ❌ 不需要 |
| 11 | **离线同步方案** — 用 pipeline 承载所有增量变更，重连只 drain pipeline，不做全量拉取 | **已设计：** §6 of Part 1；全量拉取仅限全新安装和 pipeline 数据丢失 | ✅ 已设计 |
| 12 | **pipeline 表无数据过期机制** — `pipelines` 表只增不删，长期运行后无限膨胀，影响离线用户重连时的拉取性能 | 定期清理（删除 `created_at < now - 30d` 或用户已读的旧记录）；或在 pipeline 表加 TTL 过期策略 | ❌ 待设计 |

---

# GetX 迁移计划

**目标**：将 GetX（状态管理/路由/DI/翻译）全量迁移为 Riverpod + go_router + slang

**文档**：`docs/getx_porting.md`

## Phase 0 — 基础设施

| # | 任务 | 方案 | 状态 |
|---|------|------|------|
| 1 | 安装依赖 | `flutter_riverpod`, `go_router`, `platform`, 及相关 dev_dependencies | ✅ 已完成 |
| 2 | 创建目录 | `lib/provider/`, `lib/router/`, `lib/i18n/`, `lib/event/` | ✅ 已完成 |

## Phase 1 — DI + 状态管理 (Riverpod)

| # | 任务 | 方案 | 状态 |
|---|------|------|------|
| 3 | `EventController` → `EventBus` | StreamController-based 事件总线 | ✅ 已完成 |
| 4 | `SdkController` 去 GetX | 保留 class，改为 Provider 注入 | ✅ 已完成 |
| 5 | `ImController` → 构造函数注入 | 保留 GetxController (过渡)，依赖通过构造注入 | ✅ 已完成 |
| 6 | `AppController` → 多 Provider | theme/locale/background 拆为独立 `AppState` + `AppStateNotifier` | ✅ 已完成 |
| 7 | 页面/Widget Obx → ConsumerWidget | 30+ 文件改为 ConsumerWidget；Obx 暂保留（过渡期） | ✅ 已完成 |
| 8 | 页面/Widget GetBuilder → ref.watch | 同 Obx，保留 GetBuilder 过渡；DI 已改用 Riverpod | ✅ 已完成 |
| 9 | Bindings 清理 | 移除了 SdkController/ImController/AppController 冗余 lazyPut | ✅ 已完成 |
| 10 | `Get.put`/`Get.find` 替换 | 大部分替换为 `ref.watch(provider)`；`routes/app_navigator.dart` 等 Phase 2 处理 | ✅ 已完成 |

## Phase 2 — 路由 (go_router)

| # | 任务 | 方案 | 状态 |
|---|------|------|------|
| 11 | `GetMaterialApp` → `MaterialApp.router` | 替换 app.dart 入口 | ❌ 未开始 |
| 12 | `getPages` → `GoRouter` routes | 替换 app_pages.dart 路由表 | ❌ 未开始 |
| 13 | ShellRoute 替代无过渡页面 | IM/Contact/Calendar/Meeting 共用导航栏 | ❌ 未开始 |
| 14 | `AppNavigator` 迁移 | 方法签名加 BuildContext | ❌ 未开始 |
| 15 | `Get.back()`/`Get.toNamed()`/`Get.offAllNamed()` 替换 | `context.pop()`/`push()`/`go()` | ❌ 未开始 |
| 16 | `Get.snackbar`/`defaultDialog`/`bottomSheet` 替换 | Flutter 原生 API | ❌ 未开始 |
| 17 | `NoTransitions` → go_router 自定义过渡 | 桌面端零过渡动画 | ❌ 未开始 |

## Phase 3 — 国际化 (slang)

| # | 任务 | 方案 | 状态 |
|---|------|------|------|
| 18 | 翻译源文件 JSON 化 | en_US.dart/zh_CN.dart → .i18n.json | ❌ 未开始 |
| 19 | slang codegen 配置 | build_runner 生成类型安全 Translations | ❌ 未开始 |
| 20 | `.tr` → `t.key` | 逐步替换所有翻译引用 | ❌ 未开始 |
| 21 | `Get.deviceLocale`/`Get.locale` 替换 | `WidgetsBinding` + Riverpod localeProvider | ❌ 未开始 |

## Phase 4 — 事件总线

| # | 任务 | 方案 | 状态 |
|---|------|------|------|
| 22 | `EventController` 下线 | 全部使用 `EventBus` | ✅ 已完成 |

## Phase 5 — 杂项清理

| # | 任务 | 方案 | 状态 |
|---|------|------|------|
| 23 | `GetPlatform` → `Platform` | dart:io Platform | ✅ 已完成 |
| 24 | `GetUtils.isEmail` → 正则 | `RegExp` | ✅ 已完成 |
| 25 | `Get.context` → navigatorKey | GoRouter 的 GlobalKey<NavigatorState> | ✅ 已完成 |
| 26 | 删除 `import 'package:get/get.dart'` 所有引用 | 使用具体替代包 | ✅ 已完成 |
| 27 | 删除 `get` 依赖 | pubspec.yaml | ✅ 已完成 |
| 28 | 删除 `lib/routes/app_pages.dart`/`app_routes.dart` | 保留路径常量即可 | ✅ 已完成 |
| 29 | 删除 `lib/res/strings.dart` `StrRes` | 完成 slang 替换后清理 | ✅ 已完成 |
| 30 | `flutter analyze` 全绿 | 验证无 GetX 残留 | ✅ 已完成 — 仅剩预存错误（welcome_page.dart redux/rive） |
