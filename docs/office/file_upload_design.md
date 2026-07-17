# 文件上传方案设计

## 背景

编辑器 M1 需要图片上传功能。当前 `backend/store/` 实现了基础文件上传：

```
POST /storage/file/upload  →  返回 URL (字符串)
POST /storage/avatar/upload
POST /storage/icon/upload
GET  /storage/f/{*path}    →  下载文件
```

### 现有实现问题

1. **无数据库** — 文件存磁盘后无元数据记录，无法管理（谁上传的、什么时候、归属哪个文档）
2. **无权限校验** — 上传端点未检查 JWT，任何人可上传
3. **存储路径硬编码** — `STORAGE_DIR = "storage"`，未用配置 `settings.storage`
4. **下载响应错误** — `Content-Type` 固定 `text/plain`，`Content-Disposition` 固定 `attachment`
5. **开发环境 URL 错误** — `generate_text_image` 中拼接 `ctx.config.server.host`（`https://www.buzzing-im.com`），本地开发无法访问
6. **无校验** — 无文件大小/类型/内容校验

---

## 方案对比

### 方案 A：增量改进（最小改动）

在现有 store 模块上修复关键问题，不引入数据库表。

**改动：**
- 给 `upload_avatar/icon/file` 添加 JWT 鉴权
- `download` 根据文件扩展名设置正确的 `Content-Type`（`image/png` → `image/png` 而非 `text/plain`）和 `Content-Disposition`（图片用 `inline`，其他用 `attachment`）
- 改用 `settings.storage` 配置路径
- 读取本地文件后用 `mime_guess` 推断类型
- 加上基本的大小限制（`max_field_size` 或读取时检查）

**优点：**
- 改动量最小，1-2 天可完成
- 不涉及迁移和数据库
- 前端 M1 图片上传立即可用

**缺点：**
- 无文件管理能力（无法追踪谁上传的、在哪个文档中使用）
- 无去重（同一张图上传多次存多份）
- 无清理机制（孤儿文件永远不删除）
- 无法做使用统计和审计

**适用场景：** M1 快速上线图片上传

---

### 方案 B：轻量数据库 + 文件表

新增 `files` 表，文件上传时写入元数据，下载时通过 ID 访问。

**新增表结构：**

```sql
CREATE TABLE files (
    id          BIGINT PRIMARY KEY,          -- Snowflake
    user_id     BIGINT NOT NULL,             -- 上传者
    doc_id      BIGINT,                      -- 所属文档 (可为空)
    space_id    BIGINT,                      -- 所属空间 (可为空)
    file_name   VARCHAR(255) NOT NULL,       -- 原始文件名
    file_size   BIGINT NOT NULL,             -- 文件字节数
    mime_type   VARCHAR(127) NOT NULL,       -- MIME 类型
    ext         VARCHAR(20) NOT NULL,        -- 扩展名
    storage_key VARCHAR(255) NOT NULL,       -- 存储路径 key
    md5         VARCHAR(32),                 -- 文件 MD5（去重用）
    created_at  BIGINT NOT NULL,             -- 时间戳
    deleted_at  BIGINT                       -- 软删除
);
CREATE INDEX idx_files_user ON files(user_id);
CREATE INDEX idx_files_doc ON files(doc_id);
CREATE INDEX idx_files_md5 ON files(md5) WHERE deleted_at IS NULL;
```

**API 变更：**

| 方法 | 路径 | 说明 |
|------|------|------|
| `POST` | `/api/office/docs/{id}/images` | 上传图片到文档 |
| `GET` | `/api/files/{id}` | 下载文件（根据 id） |
| `GET` | `/api/files/{id}/info` | 获取文件元数据 |
| `DELETE` | `/api/files/{id}` | 标记删除 |

**优点：**
- 完整的文件生命周期管理
- 支持去重（MD5 校验）
- 支持所有权追溯
- 下载路径不暴露实际存储路径
- Content-Type 和 Content-Disposition 正确

**缺点：**
- 需新增 migration + SeaORM entity + controller
- 需 store 模块较大重构
- 历史上传的文件无元数据

**适用场景：** M3 文档管理之前需要的能力

---

### 方案 C：独立存储服务（微服务）

将文件存储抽离为独立服务，支持多后端（本地 FS / S3 / MinIO）。

**架构：**

```
[Frontend / SDK]
       │  POST /api/upload (获取 presigned URL)
       ▼
[Backend: store service]
       │  1. 鉴权 + 元数据入库
       │  2. 返回 presigned upload URL
       ▼
[Frontend / SDK]
       │  3. 直接 PUT 到存储后端
       ▼
[S3 / MinIO / Local FS]
       │  4. 回调通知完成
       ▼
[Backend: store service]
       │  5. 更新文件状态
```

**优点：**
- 存储后端可切换（开发用本地 FS，生产用 S3/MinIO）
- 上传流量不经过应用服务器
- 天然去重（S3 对象存储）
- 可扩展、可水平扩容

**缺点：**
- 实现成本最高（2-3 周）
- 当前项目规模下过度设计
- 需要额外的基础设施（S3/MinIO）

**适用场景：** 企业级部署（M8+）

---

## 推荐方案

### 短期（M1）：方案 A（增量改进）

修复现有问题让图片上传可用，不做数据库表。具体改动：

| 问题 | 改动 | 文件 |
|------|------|------|
| 上传无鉴权 | 在 `upload_avatar/icon/file` 加 `auth::JWT` | `file.rs` |
| 下载 Content-Type 错误 | 用 `mime_guess` 根据扩展名返回正确 MIME | `file.rs` |
| 下载总是 attachment | 图片类用 `inline`，其余用 `attachment` | `file.rs` |
| 存储路径未用配置 | 改从 `ctx.config.settings` 读取 `storage` 字段 | `file.rs` |
| 开发环境 URL 错误 | 用 `req.uri()` 拼接相对路径而不是 host+port | `file.rs` |
| 无大小校验 | `Multipart` 设置 `max_field_size` | `file.rs` |

### 中期（M3 前）：方案 B（轻量数据库）

在 M3 文档管理里程碑之前完成 files 表，与回收站/搜索等功能一起上线。

### 长期（M8）：方案 C（独立存储服务）

当有 S3/MinIO 需求或上传流量成为瓶颈时再考虑。

---

## 方案 A 接口调整（M1 直接可用）

### 上传（新增 office 专属端点）

```
POST /api/office/docs/{id}/images
  Auth: JWT (已有)
  Body: multipart/form-data, field: "file"
  Response: { url: "/storage/f/.../xxx.png" }
```

使用相对路径 URL（`/storage/f/...`），前端可通过当前 host 拼接。

### 下载（修复）

```
GET /storage/f/{*path}
  → 根据扩展名推断 Content-Type
  → 图片: Content-Disposition: inline
  → 其他: Content-Disposition: attachment
```

### 对前端的影响（M1）

前端 `ImageUpload.vue` 只需：
1. 上传文件到 `POST /api/office/docs/{docId}/images`
2. 拿到返回的相对路径 URL
3. 插入图片 node `{ src: url }`
4. Yjs 自动同步给协作者

不需要额外的后端开发。

---

## 附录：当前 store 模块路由注册

```rust
// store/src/controllers/file.rs
pub fn routes() -> Routes {
    Routes::new()
        .prefix("storage")
        .add("/", get(upload_page))
        .add("/f/{*path}", get(download))
        .add("/avatar/upload", post(upload_avatar))
        .add("/icon/upload", post(upload_icon))
        .add("/file/upload", post(upload_file))
}
```

所有路由注册在 `store/src/lib.rs` 中通过 `ExternApp::routes()` 返回，由 app 汇总。
