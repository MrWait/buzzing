# 主题设计系统

## 现状

| 问题 | 描述 |
|------|------|
| `MaterialApp` 无 `theme:` | 使用 Flutter 默认 ThemeData，未配置颜色/字体 |
| 颜色定义散落 4 处 | `PageStyle` 48 个 hex 常量 + 11 个 opacity 变体 + `BuzzingColors` 语义色 + 内联 `Color(0xFF)` |
| TextStyle 膨胀 | `PageStyle.ts_XXXXXX_XXsp` 约 80 个，颜色与字号耦合 |
| 引用方式混乱 | 34 个文件混用 `PageStyle.c_xxx` / `Theme.of(context)` / `Colors.xxx` / 内联 `Color(0xFF)` |
| 暗黑模式缺失 | `AppState.theme` 死字段未使用，无 dark ThemeData |
| 零设计系统 | 无 `ThemeExtension` / `ColorScheme` / `TextTheme` / 间距圆角 token |

## 目标

1. **按语义定义** — 颜色/字体按用途分类，不按色值
2. **单向引用** — 所有 widget 只能通过 `Theme.of(context)` 或 `ThemeExtension` 引用颜色字体，禁止内联
3. **可扩展** — 暗黑模式只需追加一套 `ThemeData.dark()`
4. **可删除** — 最终移除 `lib/res/styles.dart`（约 800 行）

## 架构

```
app.dart
  └─ ThemeData (light / dark)
       ├─ colorScheme: ColorScheme.fromSeed(...)    ← Flutter M3 内置语义色
       ├─ textTheme: TextTheme(...)                  ← 6-8 级文字层级
       └─ extensions: [BuzzingTheme]                 ← 品牌私有色
```

### 1. ColorScheme — 通用语义色

使用 Material 3 `ColorScheme.fromSeed` 按 seed 色自动生成一套完整色板。覆盖约 60% 场景。

| ColorScheme 槽位 | 适用场景 | 替换目标 |
|---|---|---|
| `primary` | 主按钮、选中态、品牌强调 | `c_3370FF`, `c_1D6BED`, `actionBlue` |
| `onPrimary` | primary 上的文字/图标 | `c_FFFFFF`, `textWhite` |
| `secondary` | 次要操作、标签 | `c_5496EB`, `c_418AE5` |
| `surface` | 页面背景、卡片背景 | `c_FFFFFF`, `c_FDFEFF`, `cardWhite` |
| `surfaceVariant` | 分割线、禁用背景、输入框背景 | `c_F0F0F0`, `c_F5F5F5`, `c_EAEAEA` |
| `outline` | 边框、分割线、未选中态 | `c_D8D8D8`, `c_D7D7D7`, `c_C7C7C8` |
| `outlineVariant` | 弱化边框 | `c_EEEEEE`, `c_F1F1F1` |
| `onSurface` | 主文字 | `c_16191C`, `c_333333`, `primaryValue` |
| `onSurfaceVariant` | 副文字、占位符 | `c_666666`, `c_898989`, `c_959595`, `subTextColor` |
| `error` | 错误提示、删除操作 | `c_F44038` |
| `shadow` | 阴影 | — |

### 2. ThemeExtension — 品牌私有语义

`ColorScheme` 覆盖不了的业务色：

```dart
class BuzzingTheme extends ThemeExtension<BuzzingTheme> {
  final Color? success;     // c_10CC64
  final Color? warning;     // c_FFC563
  final Color? link;        // c_3370FF
  final Color? headerBg;    // 顶栏背景 c_03091C
  final Color? navBarBg;    // 导航栏背景
  final Color? mentionBg;   // @提醒背景 c_E8F2FF
  final Color? stickerBg;   // 贴纸背景
  final Color? online;      // 在线绿点

  const BuzzingTheme({
    required this.success,
    required this.warning,
    required this.link,
    required this.headerBg,
    required this.navBarBg,
    required this.mentionBg,
    required this.stickerBg,
    required this.online,
  });

  static const light = BuzzingTheme(
    success: Color(0xFF10CC64),
    warning: Color(0xFFFFC563),
    link: Color(0xFF3370FF),
    headerBg: Color(0xFF03091C),
    navBarBg: Color(0xFF24292E),
    mentionBg: Color(0xFFE8F2FF),
    stickerBg: Color(0xFFFDFEFF),
    online: Color(0xFF10CC64),
  );

  static const dark = BuzzingTheme(
    success: Color(0xFF10CC64),
    warning: Color(0xFFFFC563),
    link: Color(0xFF5496EB),
    headerBg: Color(0xFF1A1C1E),
    navBarBg: Color(0xFF1A1C1E),
    mentionBg: Color(0xFF1B3A5C),
    stickerBg: Color(0xFF2C2C2C),
    online: Color(0xFF10CC64),
  );

  @override
  BuzzingTheme copyWith({...}) => ...;

  @override
  BuzzingTheme lerp(ThemeExtension<BuzzingTheme>? other, double t) => ...;
}
```

### 3. TextTheme — 文字层级

8 级文字层级替代 ~80 个 `ts_` 常量：

| TextTheme 槽位 | fontSize | fontWeight | 场景 | 替换目标 |
|---|---|---|---|---|
| `displayLarge` | 30 | w600 | 页面大标题 | `lagerTextSize` |
| `headlineMedium` | 23 | w600 | 区块标题 | `bigTextSize` |
| `titleLarge` | 18 | w600 | 卡片标题、弹窗标题 | `normalTextSize` + bold |
| `titleMedium` | 16 | w500 | 列表项标题、导航文字 | `middleTextWhiteSize` |
| `titleSmall` | 14 | w500 | 次级标题 | — |
| `bodyLarge` | 16 | w400 | 正文 | `normalTextSize` |
| `bodyMedium` | 14 | w400 | 正文小字 | `smallTextSize` |
| `bodySmall` | 12 | w400 | 辅助文字、时间戳 | `minTextSize` |
| `labelLarge` | 16 | w500 | 按钮文字 | — |
| `labelSmall` | 11 | w400 | 角标、小标签 | — |

字体大小不使用 `sp` 缩放（桌面端 identity 映射），直接用固定 px 值。

### 4. 引用规范

```dart
// ✅ 正确
Theme.of(context).colorScheme.primary
Theme.of(context).textTheme.bodyMedium
Theme.of(context).extension<BuzzingTheme>()!.link

// ❌ 禁止
PageStyle.c_3370FF
PageStyle.ts_333333_14sp
Color(0xFF3370FF)
Colors.blue
```

## 迁移步骤

### Phase 1 — 基础设施

| # | 任务 | 描述 |
|---|------|------|
| 1 | 创建 `lib/res/theme.dart` | 定义 `BuzzingTheme` (ThemeExtension) + `AppTheme.light`/`dark` (ThemeData) |
| 2 | 配置 `app.dart` | `MaterialApp.router` 添加 `theme:` / `darkTheme:` / `themeMode:`，连接 `AppState.theme` |
| 3 | 测试编译 | 确保 Phase 1 不影响现有功能 |

### Phase 2 — 替换 PageStyle 颜色引用

| # | 任务 | 涉及文件数 |
|---|------|-----------|
| 4 | `c_FFFFFF` → `colorScheme.surface` | ~34 文件 |
| 5 | `c_3370FF` / `c_1D6BED` → `colorScheme.primary` | ~30 文件 |
| 6 | `c_F0F0F0` / `c_F5F5F5` / `c_EAEAEA` → `colorScheme.surfaceVariant` | ~20 文件 |
| 7 | `c_D8D8D8` / `c_C7C7C8` → `colorScheme.outline` | ~15 文件 |
| 8 | `c_666666` / `c_898989` / `c_959595` → `colorScheme.onSurfaceVariant` | ~25 文件 |
| 9 | `c_10CC64` / `c_FFC563` / `c_E8F2FF` → `BuzzingTheme.xxx` | ~10 文件 |
| 10 | `c_03091C` / `c_24292E` → `BuzzingTheme.headerBg`/`navBarBg` | ~5 文件 |
| 11 | `c_000000_opacityXXp` → `colorScheme` 或 `BuzzingTheme` | ~10 文件 |

### Phase 3 — 替换 TextStyle 引用

| # | 任务 | 涉及文件数 |
|---|------|-----------|
| 12 | `ts_XXXXXX_30sp` → `textTheme.displayLarge` | ~5 文件 |
| 13 | `ts_XXXXXX_23sp` → `textTheme.headlineMedium` | ~5 文件 |
| 14 | `ts_XXXXXX_18sp` → `textTheme.titleLarge` | ~15 文件 |
| 15 | `ts_XXXXXX_16sp` → `textTheme.titleMedium` / `bodyLarge` | ~20 文件 |
| 16 | `ts_XXXXXX_14sp` → `textTheme.bodyMedium` / `titleSmall` | ~30 文件 |
| 17 | `ts_XXXXXX_12sp` → `textTheme.bodySmall` | ~20 文件 |

### Phase 4 — 清理

| # | 任务 | 描述 |
|---|------|------|
| 18 | 删除 `lib/res/styles.dart` | 移除 `PageStyle` / `BuzzingColors` / `BuzzingConstant` |
| 19 | 删除 `lib/res/theme.dart` 占位符 | 内容已移至新文件 |
| 20 | `flutter analyze` 全绿 | 验证无遗留引用 |

## 相关文件

| 文件 | 角色 |
|------|------|
| `lib/res/styles.dart` | 待删除 — 当前所有颜色/字号定义 |
| `lib/res/theme.dart` | 待重写 — 新 `BuzzingTheme` + `AppTheme` |
| `lib/provider/app_state_provider.dart` | `AppState.theme` 字段待激活 |
| `lib/app.dart` | 待配置 `theme:` / `darkTheme:` / `themeMode:` |

## 参考

- [Material 3 ColorScheme](https://api.flutter.dev/flutter/material/ColorScheme-class.html)
- [Material 3 TextTheme](https://api.flutter.dev/flutter/material/TextTheme-class.html)
- [Flutter ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)
