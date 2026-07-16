# 在线文档产品级需求 & 里程碑规划

## 当前能力摘要

| 维度 | 现状 |
|------|------|
| 编辑器 | ProseMirror + y-prosemirror，基础 schema（heading/paragraph/list/image/link/strong/em/code） |
| 协作 | Yjs WebSocket + BroadcastGroup，协作光标，30s 持久化 |
| API | REST JSON（非 protobuf），Spaces + Docs CRUD + edit-url |
| 客户端 | Web SPA 完整（编辑器+列表），Flutter 仅列表+空间树，跳转浏览器打开编辑 |
| 权限 | `document_members` 表存在，但无 API 暴露 |
| 测试 | 无 |

---

## 里程碑总览

| # | 名称 | 工作量估算 | 核心交付 |
|---|------|-----------|----------|
| M1 | 编辑器完善 | 2-3 周 | 完整工具栏 + 图片/表格/代码块 + 文档标题编辑 |
| M2 | 协作增强 | 1-2 周 | 在线状态列表 + 冲突提示 + 手动保存指示 |
| M3 | 文档管理 | 2-3 周 | 搜索 + 回收站 + 移动/复制 + 星标/标签 |
| M4 | 权限与分享 | 2 周 | 成员管理 + 分享链接 + 角色控制 |
| M5 | 版本历史 | 1-2 周 | 版本列表 + Diff + 回滚 |
| M6 | Flutter 原生编辑器 | 3-4 周 | Flutter 端内嵌 ProseMirror WebView + 离线编辑 |
| M7 | 质量与规模化 | 2-3 周 | 自动化测试 + 大文档性能 + 监控告警 |
| M8 | 企业功能 | 3-4 周 | 模板库 + 评论/批注 + 导出导入 + 审计日志 |

---

## M1 — 编辑器完善 (Phase 1 Pro)

### 目标
补齐编辑器核心功能，达到可用级别。

### 需求

#### 1.1 工具栏组件
- [ ] 实现完整工具栏（Toolbar.vue）：加粗、斜体、下划线、删除线、标题(H1-H6)、引用、有序/无序列表、任务列表、代码块、分割线、链接、图片、清除格式
- [ ] 工具栏根据选区状态自动切换 active/inactive
- [ ] 工具栏紧凑布局，可折叠

#### 1.2 新增节点类型
- [ ] 任务列表 (taskList / taskItem) — checkbox 可点击切换
- [ ] 代码块 (codeBlock) — 带语言标记 + 语法高亮
- [ ] 表格 (table) — 创建表格、增删行列、合并单元格
- [ ] 下划线 (underline) + 删除线 (strike) mark
- [ ] 行内代码 (code) mark 样式优化

#### 1.3 文档标题
- [ ] 编辑器顶部直接编辑标题（非 dialog）
- [ ] 标题自动保存（debounce 500ms 后 PATCH title）

#### 1.4 图片上传
- [ ] 图片选择器（本地文件 / 粘贴 / 拖拽）
- [ ] 后端文件上传接口（复用 store 模块或新增 office 上传）
- [ ] 图片上传进度指示
- [ ] 图片展示（最大宽度、点击查看原图）
- [ ] 图片删除

#### 1.5 链接
- [ ] 链接插入 dialog（URL + 文本）
- [ ] 链接可点击打开（新窗口）
- [ ] 链接编辑/移除

#### 1.6 快捷键
- [ ] Ctrl+B / Ctrl+I / Ctrl+U / Ctrl+Shift+S
- [ ] Ctrl+Shift+] / Ctrl+Shift+[ (缩进/反缩进)
- [ ] Tab 缩进列表项
- [ ] Ctrl+K 插入链接
- [ ] Ctrl+Shift+C 代码块
- [ ] 斜杠命令菜单 (/menu)

### 交付产物
- `frontend/src/views/office/components/Toolbar.vue` 大重构
- `frontend/src/views/office/components/ImageUpload.vue`
- `frontend/src/views/office/components/LinkDialog.vue`
- `frontend/src/views/office/components/SlashMenu.vue`
- 后端文件上传端点
- 数据库迁移：file_attachments 表（可选）

---

## M2 — 协作增强

### 目标
提升多人实时协作的体验和可靠性。

### 需求

#### 2.1 在线用户列表
- [ ] 侧边栏展示所有在线协作者（头像+名字+活跃状态）
- [ ] 区分当前用户和远程用户

#### 2.2 冲突与同步反馈
- [ ] 保存状态指示器（"已保存" / "保存中" / "未保存" / "离线"）
- [ ] Yjs 连接状态提示（已连接 / 重连中 / 断开）
- [ ] 冲突时提示用户有并发修改

#### 2.3 光标与选区改进
- [ ] 协作者光标带上名字标签
- [ ] 不同用户使用不同颜色（从调色板分配）
- [ ] 选区高亮（选中文本的背景色）

#### 2.4 协作边界
- [ ] 文档打开时获取当前在线人数
- [ ] BroadcastGroup 扩容（当前 32 上限改为可配置）
- [ ] 连接数超限时返回友好提示

### 交付产物
- `frontend/src/views/office/components/Collaborators.vue` 重构
- `frontend/src/views/office/components/SyncStatus.vue`
- 后端 ws.rs 配置化 max_clients

---

## M3 — 文档管理

### 目标
提供完整的文档生命周期管理能力。

### 需求

#### 3.1 全文搜索
- [ ] 后端：文档标题 + 内容的 PostgreSQL 全文检索
- [ ] 后端：POST /api/office/docs/search?q=xxx
- [ ] 前端：搜索栏（全局搜索 + 空间内搜索）
- [ ] 搜索结果高亮显示匹配文本

#### 3.2 回收站
- [ ] 软删除：delete 改为 trashed_at 标记
- [ ] 数据库迁移：documents 表加 `trashed_at` 和 `deleted_at` 字段
- [ ] 回收站页面：列出已删除文档，显示剩余恢复时间
- [ ] 恢复文档
- [ ] 永久删除（30 天后自动清理或手动）

#### 3.3 移动/复制
- [ ] 文档右键菜单："移动到…" / "复制到…"
- [ ] 空间选择弹窗
- [ ] 复制文档内容到目标空间（深拷贝 Yjs state）

#### 3.4 星标/收藏
- [ ] 数据库迁移：document_stars 表 (user_id, doc_id, created_at)
- [ ] 前端：文档 item 星标 toggle
- [ ] 侧边栏：星标文档入口
- [ ] 后端：GET /api/office/docs/starred

#### 3.5 最近文档
- [ ] 后端：记录文档访问时间 (document_visits 或更新 visited_at)
- [ ] 后端：GET /api/office/docs/recent
- [ ] 前端：主页入口"最近文档"

#### 3.6 空间管理
- [ ] 空间重命名（Flutter + Web 右键菜单）
- [ ] 空间颜色/图标
- [ ] 空间排序（拖拽）

### 交付产物
- 数据库迁移 (soft delete, stars, visits)
- 后端搜索、回收站、星标、最近端点
- 前端搜索栏、回收站页面、右键菜单

---

## M4 — 权限与分享

### 目标
实现文档级权限控制和外部分享。

### 需求

#### 4.1 成员管理 API
- [ ] 暴露 `document_members` CRUD 端点：
  - GET /api/office/docs/{id}/members
  - POST /api/office/docs/{id}/members
  - DELETE /api/office/docs/{id}/members/{user_id}
  - PATCH /api/office/docs/{id}/members/{user_id} (改角色)
- [ ] 角色定义：viewer(0) / editor(1) / owner(2)
- [ ] 权限校验中间件：owner 可管理成员，editor 可编辑，viewer 只读

#### 4.2 共享链接
- [ ] 后端：生成分享链接（含 token）
- [ ] 后端：POST /api/office/docs/{id}/share — 创建链接（可选过期时间、密码）
- [ ] 后端：GET /share/{token} — 解析 token，返回文档
- [ ] 前端：分享 dialog（复制链接、设置权限、过期时间）
- [ ] 前端：通过分享链接访问的只读视图

#### 4.3 UI 集成
- [ ] 文档列表头部显示权限角色图标
- [ ] 只读模式下禁用编辑器交互
- [ ] 空间级权限（可选：空间成员继承到文档）
- [ ] 用户搜索器（复用 contact 组件）

### 交付产物
- 后端成员管理端点
- 后端分享链接端点
- 前端分享 dialog + 只读视图
- 权限校验中间件

---

## M5 — 版本历史

### 目标
提供文档版本管理能力。

### 需求

#### 5.1 版本快照
- [ ] 将当前 30s 周期保存改为全量快照 + 增量更新
- [ ] 每次保存时创建版本记录（version_id, doc_id, snapshot, timestamp, author）
- [ ] 数据库迁移：document_versions 表
- [ ] 后端：GET /api/office/docs/{id}/versions

#### 5.2 版本对比
- [ ] 版本列表 UI（时间轴样式）
- [ ] 选中两个版本进行 diff（文本级差异高亮）
- [ ] 利用 Yjs 的 `encode_state_as_update` + `apply_update` 做 diff

#### 5.3 版本回滚
- [ ] 恢复至历史版本（创建新版本，内容回溯）
- [ ] 回滚确认 dialog
- [ ] 回滚后通知其他在线协作者

#### 5.4 自动版本策略
- [ ] 保留策略：保留最近 N 个版本 + 每小时一个版本（>24h）
- [ ] 手动创建命名版本（"发布 v1.0"）

### 交付产物
- document_versions 表
- 后端版本 CRUD
- 前端版本时间轴 + Diff 视图

---

## M6 — Flutter 原生编辑器 (桌面端)

### 目标
Flutter 客户端无需跳转浏览器即可编辑文档。

### 方案选择
由于 ProseMirror 是 Web 技术栈，Flutter 端有两种路径：

**方案 A：WebView 嵌入（推荐，2-3 周）**
- Flutter 使用 `webview_flutter` 或 `flutter_inappwebview` 加载 SPA 编辑器
- 通过 JS Bridge 传递 token、docId 等参数
- 优点：复用 Web 端全部编辑器能力，同步开发
- 缺点：WebView 性能略低于原生

**方案 B：Flutter 原生编辑器（4-6 周）**
- 使用 `applied_ml ProseMirror` 的 Flutter 移植或 `flutter_quill` + Yjs 绑定
- 需要自行实现 Yjs 同步层
- 优点：性能最优
- 缺点：开发量大，与 Web 端功能需同步维护

### 推荐：方案 A

### 需求
- [ ] Flutter WebView 加载编辑器 SPA
- [ ] JS Bridge 传递 auth token + docId
- [ ] 编辑器内工具栏交互（部分可通过 Flutter 原生覆盖层实现）
- [ ] 离线编辑支持（Service Worker + 本地 Yjs 状态缓存）
- [ ] 网络恢复时自动同步

### 交付产物
- `buzzing/lib/page/office/editor_view.dart`
- `buzzing/lib/widget/webview_editor.dart`

---

## M7 — 质量与规模化

### 目标
确保系统在大文档、多用户场景下稳定可靠。

### 需求

#### 7.1 自动化测试
- [ ] 后端测试 (`backend_test/`)：Spaces CRUD, Docs CRUD, WebSocket 连接
- [ ] 前端测试：编辑器渲染、工具栏交互、协作同步
- [ ] SDK 测试 (`buzzing/sdk_test/`)：BizOffice API 调用
- [ ] 每项测试关联 spec 文件

#### 7.2 大文档性能
- [ ] 基准测试：10 万字的文档加载/编辑/保存耗时
- [ ] 内容分块加载（超过 1MB 的 Yjs state 分片传输）
- [ ] 编辑器虚拟滚动（超长文档只渲染可视区域）
- [ ] 内存泄漏检测（长期打开编辑器后内存对比）

#### 7.3 可靠性
- [ ] WebSocket 断线重连退化策略（指数退避）
- [ ] 编辑内容本地缓存（localStorage + IndexedDB）
- [ ] 保存失败时的冲突处理（服务端版本 vs 本地版本）

#### 7.4 监控告警
- [ ] Yjs 文档内存使用指标（Prometheus）
- [ ] WebSocket 连接数监控
- [ ] 保存失败告警（保存队列积压超过阈值）
- [ ] 慢查询日志

### 交付产物
- 测试用例 + spec 文件
- 性能测试报告
- 监控指标 + 告警规则

---

## M8 — 企业功能

### 目标
提供企业级知识管理能力。

### 需求

#### 8.1 文档模板
- [ ] 模板管理：创建/编辑/删除模板
- [ ] 新建文档时选择模板
- [ ] 默认模板（空白文档、会议记录、周报、项目计划）
- [ ] 后端：templates 表 + CRUD API

#### 8.2 评论/批注
- [ ] 选中文本 → 添加评论
- [ ] 评论列表侧边栏
- [ ] @提及用户（通知中心联动）
- [ ] 评论解析/回复
- [ ] 批注模式与编辑模式切换

#### 8.3 导出/导入
- [ ] 导出：Markdown, PDF, DOCX (通过 `pandoc` 或 WASM 转换)
- [ ] 导入：Markdown → Yjs → ProseMirror
- [ ] 注意：导入需保留标题/列表/表格等结构化信息

#### 8.4 审计日志
- [ ] 记录文档创建、编辑、分享、删除等操作
- [ ] 后端：audit_logs 表
- [ ] 管理端：审计日志查询

### 交付产物
- templates 表 + 模板选择 UI
- 评论系统
- 导出/导入功能
- 审计日志

---

## 优先级矩阵

| 功能 | 用户价值 | 实现成本 | 优先级 |
|------|---------|---------|--------|
| 工具栏 | ★★★★★ | 低 | P0 |
| 图片上传 | ★★★★★ | 中 | P0 |
| 搜索 | ★★★★ | 中 | P1 |
| 回收站 | ★★★★ | 低 | P1 |
| 权限/分享 | ★★★★★ | 中 | P1 |
| 版本历史 | ★★★ | 高 | P2 |
| Flutter 编辑器 | ★★★★ | 中-高 | P2 |
| 评论批注 | ★★★ | 高 | P2 |
| 表格/代码块 | ★★★★ | 中 | P1 |
| 导出导入 | ★★★ | 中 | P3 |
| 模板 | ★★★ | 中 | P3 |
| 审计日志 | ★★ | 低 | P3 |

---

## 依赖关系

```
M1 ──> M2 ──> M5
  │
  └──> M3 ──> M8
        │
        └──> M4
              │
              └──> M6

M7 (质量) ── 贯穿所有里程碑
```

- M1 是基础，所有后续依赖编辑器能力的增强
- M2 可并行或紧随 M1
- M3 和 M4 可并行开发
- M5 依赖 M2（协作）
- M6 依赖 M4（权限）
- M7 贯穿全流程
- M8 依赖 M3 + M4
