# 文档业务 Phase 1 — 任务跟踪

## 后端

### 数据库

- [x] `1` 数据库迁移：documents / document_spaces / document_members 表
- [x] `2` sea-orm 实体定义 + 基础 CRUD service

### REST API

- [x] `3` Spaces REST 路由 + controller
- [x] `4` Docs REST 路由 + controller
- [x] `5` 后端 auth/login API（或复用现有 user 接口）
- [x] `6` 鉴权中间件集成（JWT 验证）

### Yjs 协作

- [x] `7` Yjs WebSocket handler + BroadcastGroup 集成
- [x] `8` Yjs 持久化逻辑（定时快照 + 加载）

### 部署

- [x] `9` rust-embed 静态文件集成 + 路由注册

---

## SDK

- [x] `10` BizOffice trait（create / list / get / update / delete / getEditUrl / listSpaces / createSpace）
- [x] `10a` HTTP JSON 调用实现（走 `/api/office/*`，不走 protobuf）

---

## Flutter 客户端

- [x] `11` 文档列表页面 + Riverpod Notifier
- [x] `12` 空间树组件

---

## Web 前端 (Vue3 SPA)

### 项目初始化

- [x] `13` Vue3 + Vite + TypeScript 项目初始化 + 目录结构
- [x] `14` Pinia 状态管理 + axios 拦截器 + Vue Router + 导航守卫

### 页面

- [x] `15` 登录页面 LoginView + 鉴权流程
- [x] `16` 主页 HomeView（空间树 + 文档列表）

### 编辑器

- [x] `17` ProseMirror 编辑器集成 + y-prosemirror 绑定
- [x] `18` 协作光标/选中 UI

---

## 联调测试

- [ ] `19` Web 端联调 + 测试
- [ ] `20` Flutter ↔ Web 端到端联调

---

## 依赖关系

```
DB Migration ──> sea-orm Models ──> REST Controllers
                                        │
                                        ├──> SDK BizOffice ──> Flutter UI
                                        │
                                        └──> Vue3 SPA (可并行开发)
                                              │
Yjs WS Handler ──> Yjs Persistence ──────────┘
```
