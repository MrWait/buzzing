# Buzzing

Buzzing 是一个功能丰富的 IM 工具软件（类飞书/钉钉/Slack），包含完整的服务端、客户端。
目标包括以下几点：
- 安全性：可独立部署，所有产生的数据都拥有完全自主权。
- 易部署：服务端为单体结构，打包为单个文件即可部署。外部仅依赖 PG，30 分钟即可搭建完整运行环境。
- 高性能：整体使用 Rust + Flutter 实现，为性能而生，完全摆脱基于 web 技术的弊端。
- 多功能：提供了 IM、日历、文档、视频会议等常用功能，可满足大部分核心使用场景。

目前仅一人开发，仍处于功能验证阶段。


# 服务端部署
常用命令都在 justfile 中，大部分命令都可以通过 just 运行。如果新增命令或脚本，建议添加到 justfile。

## 安装依赖
- 安装 PostgreSql。
- 安装 rust 工具链。
- 安装 just 工具，可使用 `cargo install just`。

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

目前待定问题：
 - 文档：使用 flutter or web 技术栈。flutter 侧可参考 Appflowy，在客户端中使用体验更好，但 web 支持约等于无。相对 web 技术栈更成熟，生态更好，但很难集成到 flutter 中（影响客户端体验）。
 - RTC：webrtc 项目在 flutter 和 rust 中均有支持，但未进行验证。
 - 多 union：多个私有化部署的服务之间进行互联。

## 功能完善
补充和完善各业务功能，暂未开始。
