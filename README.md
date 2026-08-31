# Buzzing

Buzzing 是一个功能丰富的 IM 工具软件（类飞书/钉钉/Slack），包含完整的服务端、客户端。
目标包括以下几点：
- 安全性：可独立部署，所有产生的数据都拥有完全自主权。
- 易部署：服务端为单体结构，打包为单个文件即可部署。外部仅依赖 PG，30 分钟即可搭建完整运行环境。
- 高性能：整体使用 Rust + Flutter 实现，为性能而生，完全摆脱基于 web 技术的弊端。
- 多功能：提供了 IM、日历、文档、视频会议等常用功能，可满足大部分核心使用场景。

目前仅一人开发，仍处于功能验证阶段。大部分代码使用 vibe coding 模式由 AI 实现，所有代码（服务端、客户端、SDK、web）在同一个仓库，简化管理模式，也方便 AI 获取完整上下文。

# 服务端部署
常用命令都在 justfile 中，大部分命令都可以通过 just 运行。如果新增命令或脚本，建议添加到 justfile。

## 安装依赖
- 安装 PostgreSql。
- 安装 rust 工具链。
- 安装 just 工具，可使用 `cargo install just`。
- 安装 xmake，用于简化任务执行。

## 配置
服务端使用 loco-rs 框架，配置文件在 backend/base/config。

服务端强制使用 TLS 加密，需要自行准备 SSL 证书。可以使用自签名证书，存储在 backend/base/assets/cert/ 中。

需要修改配置文件中 server.port, server.host，其中 host 影响 URL 生成，务必使用有意义的值，且和证书对应。
修改 database.uri, queue.uri，配置 DB（queue 复用 Postgres）。
修改 auth.jwt.secret，使用自定义的密钥。
其他配置可参考 loco-rs 项目文档。

## 启动
直接运行 `just ss` 即可，实际会在 backend/base 目录下，运行 `cargo loco start`。

## 初始化数据
需要设置 BUZZING_URL 环境变量。
utils/init.js 用于生成默认用户数据，可作为测试使用。不要在生产环境使用。

依赖 proto 文件生成，因此需要在 utils 下安装 node 依赖:
```
npm install
npm proto
```

服务端启动后，运行 `just init_data` 即可。

# 客户端运行
目前客户端仅适配 Macos 和 Windows，未适配移动端，建议使用桌面端进行体验。
直接运行:
```
macos: just csm
windows: just csw
```

# Roadmap
## 验证阶段
完成初步技术验证，目的是为每个业务模块搭建基础能力，确定技术路线。

| 业务 ｜ 目标 ｜ 状态 ｜ 说明 ｜
| IM  ｜ 实现完整的会话、消息等能力 | 进行中 | 已完成会话、消息，已读、reaction 补齐中  |
| 文档 ｜ 实现基本的文档、wiki，支持协同编辑、简单的特性 ｜完成 ｜ 暂时不考虑客户端，仅支持 web 端。后续等待 flutter 多窗口稳定后，考虑增加客户端支持  ｜
| VC | 基于 mesh 的会议，支持 web、桌面端互通 ｜ 完成 ｜ 未实现 SFU，最多 4 方会议 ｜
| 开放平台 | 实现 bot 功能 ｜进行中 ｜ 后续考虑外部应用、faas 等 ｜

目前待定问题：
 - 多 union：多个私有化部署的服务之间进行互联，目前暂无明确需求。

## 功能完善
补充和完善各业务功能，暂未开始。

# License

This project is released under **Business Source License 1.1 (BSL‑1.1)**.
> BSL‑1.1 is a source‑available license, **not an OSI‑approved open‑source license**.

- ✅ **Personal / Academic / Non‑profit non‑commercial use**: Free of charge.
  Individuals, academic institutions and non‑profit organizations may use, modify for non‑commercial purposes.

- 💰 **Commercial Use Requirement**:
  All commercial usage (including internal business deployment, building commercial SaaS/cloud services, embedding into commercial products) requires purchasing a separate commercial license from copyright holder.

For commercial licensing, pricing and contract: contact **hanlianzhen@outlook.com**

### Auto‑conversion
Each released version will automatically convert to **Apache‑2.0** on its Change Date (4‑year protection window per release).
After that date, that version becomes fully open‑source with no commercial restrictions.

Full license text: [LICENSE](./LICENSE)
