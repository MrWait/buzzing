# 文档模块未完成项

> Phase A (M1-M4) / Phase B 中搁置、推迟或决定暂不实现的项，后续按阶段拾取。

---

## M1 — 编辑器完善

- [ ] **协作同步验收**：`M1 验收清单` 中 "协作同步正常" 移入 M2 联调验证（见 M2 验收）
- [ ] **后端 API 性能验证**：无性能退化 → 移入 M12 自动化测试
- [ ] **代码块语言选择**：推迟到 M9
- [ ] **表格右键菜单（增删行列）**：推迟到 M9

## M2 — 协作增强

- [ ] **3 人联调**：同时打开同一文档，光标带名字标签正确显示
- [ ] **断网恢复联调**：一人断网 30 秒后恢复，编辑内容完整同步
- [ ] **保存状态过渡**：顶栏在编辑 → 保存 → 空闲三个阶段过渡自然
- [ ] **连接超限友好提示**：Yjs 房间超 `BUZZING_YJS_MAX_CLIENTS` 时前端弹窗提示
- [ ] **冲突提示**：Yjs CRDT 天然无冲突，转为观测指标（移入 M12）

## M3 — 文档管理

- [ ] **搜索性能验证**：万级文档 P50 < 300ms
- [ ] **回收站定时清理**：30 天后自动 purge（后端 1h 定时任务已挂，待验证）
- [ ] **拖拽 + 面包屑验收**：子页面可拖拽调整层级，面包屑正确显示
- [ ] **星标/最近入口验收**：在主页可用
- [ ] **Cmd+K 全局搜索验收**：跨空间跳转正常
- [ ] **文档列表实时同步**：REST 拉取 → WebSocket/SSE/轮询推送

## M4 — 权限与分享

- [ ] **空间级成员表**（`space_members`）：暂缓，随 M7 知识库层补齐
- [ ] **`require_role` 继承**：回退到空间成员读取角色，依赖上一条
- [ ] **Viewer 模式隐藏工具栏**：FloatingToolbar / SlashMenu 在 viewer 下隐藏或禁用
- [ ] **文档列表角色徽章**：列表项右侧显示 "所有者 / 编辑 / 评论 / 查看"
- [ ] **用户搜索器**：当前使用 user_id 输入，待接入组织通讯录后升级
- [ ] **SDK trait 补齐**：M4 相关 trait 方法（`BizOffice`），HTTP 客户端实现

## M6 — 多端支持（暂不实现）

> 以下两项为 Phase B 中的 Flutter 端工作，因当前无 Flutter 开发需求，标记为暂不实现。

- [ ] **Flutter WebView 容器**：`webview_flutter` 嵌入 SPA 编辑器 + JS Bridge 双向通信
- [ ] **Flutter 移动端只读浏览**：展示后端渲染 HTML，文档列表 → 点击 → 只读打开

## M9 — 富组件与体验（暂不实现）

> M9.2/9.3/9.6/9.7 推迟，当前无明确的用户需求。

### 9.2 富媒体嵌入
- [ ] **视频** `video` node：内部上传 + YouTube/Bilibili 外链嵌入
- [ ] **音频** `audio` node：`<audio controls>`
- [ ] **附件** `fileAttachment` node：文件卡片（图标 + 名称 + 大小 + 下载）
- [ ] **外链预览** `linkPreview` node：unfurl（后端抓取 og: metadata）

### 9.3 公式与图表
- [ ] 安装 `katex` npm 包 + CSS
- [ ] **行内公式** `math_inline` node：KaTeX 渲染
- [ ] **块级公式** `math_display` node
- [ ] **Mermaid 图** `mermaid` node：mermaid.render()

### 9.6 表格增强
- [ ] `TableContextMenu.vue`：右键增删行列
- [ ] 单元格背景色、对齐方式
- [ ] 排序（点击表头）

### 9.7 表情反应
- [ ] DB 迁移：`document_reactions` 表
- [ ] 后端 CRUD（toggle reaction）
- [ ] 前端反应栏 + Emoji 选择器

## Phase A 交叉事项（贯穿）

- [ ] **`backend_test/test/office/`**：添加自动化测试脚本（`office.spec.md` + `office.test.js`）
- [ ] **`buzzing/sdk_test/`**：添加 BizOffice 测试
