# Windows: cmd.exe for both normal and [script] recipes.
# macOS/Linux: change to:
#   set shell := ["sh", "-c"]
#   set script-interpreter := ["sh", "-c"]
set shell := ["cmd.exe", "/c"]
set script-interpreter := ["cmd.exe", "/c"]

# 服务端 DB 重置
[working-directory: 'backend/base']
dr:
    cargo loco db reset

# 服务端 DB 迁移
[working-directory: 'backend/base']
dm:
    cargo loco db migrate

# 服务端通过 DB 生成 entities 代码
[working-directory: 'backend/base']
de:
    cargo loco db entities

# 服务端启动（开发模式，读取 frontend/dist 文件系统，修改前端后无需重编）
[working-directory: 'backend']
sd:
    cargo run -p app --no-default-features

# 服务端启动（生产模式，embed 前端资源到二进制）
[working-directory: 'backend/base']
ss:
    cargo loco start

# 服务端构建 release（embed 前端资源到二进制）
[working-directory: 'backend']
sr:
    cargo build --release -p app --features base/embed

# 客户端在 macos 平台启动
[macos]
[working-directory: 'buzzing']
csm:
    flutter run -d macos

# 客户端在 windows 平台启动
[working-directory: 'buzzing']
csw:
    flutter run -d windows

# 客户端在 macos 平台构建
[macos]
[working-directory: 'buzzing']
cbm:
    flutter build macos

# 客户端生成 protobuf 的 idl
[script]
[working-directory: 'buzzing']
cidl:
    python3 util.py -c idl -t dart -s ../proto -o ./lib/models/idl/ || python util.py -c idl -t dart -s ../proto -o ./lib/models/idl/

# 客户端生成 debug 模式 SDK
[script]
[working-directory: 'buzzing']
clib:
    python3 util.py -c lib -t debug -i ../sdk || python util.py -c lib -t debug -i ../sdk

# 客户端生成 release 模式 SDK
[script]
[working-directory: 'buzzing']
cdeploy:
    python3 util.py -c lib -t release -i ../sdk || python util.py -c lib -t release -i ../sdk

# 客户端构建。不建议使用
[script]
[working-directory: 'buzzing']
cbuild:
    python3 util.py -c build || python util.py -c build

# 未知
[working-directory: 'buzzing']
cjson:
    dart run build_runner build

# 初始化用户数据（账户、租户、部门）。默认 init.json，可用 -s 指定文件
[windows]
[script]
[working-directory: 'utils']
init_data:
    set NODE_TLS_REJECT_UNAUTHORIZED=0
    node init.js

[unix]
[script]
[working-directory: 'utils']
init_data:
    NODE_TLS_REJECT_UNAUTHORIZED=0 node init.js

# 使用测试租户数据初始化
[windows]
[script]
[working-directory: 'utils']
init_data_test:
    set NODE_TLS_REJECT_UNAUTHORIZED=0
    node init.js -s ./init_test.json

[unix]
[script]
[working-directory: 'utils']
init_data_test:
    NODE_TLS_REJECT_UNAUTHORIZED=0 node init.js -s ./init_test.json

# 修复 macos 端 pod 版本问题
[macos]
[script]
[working-directory: 'buzzing/macos']
client_macos_fix_pod:
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    pod install --repo-update

# 客户端生成多语言代码
[working-directory: 'buzzing']
client_gen_slang:
    dart run slang

# SDK 集成测试 (编译 Rust 库 + 运行 dart 测试)
[working-directory: 'buzzing/sdk_test']
sdk_test:
    bash run.sh

# 后端业务测试 (需要服务端运行中)
[working-directory: 'backend_test']
backend_test:
    npm run test:business

# 后端 smoke 测试 (连通性 + 登录流程)
[working-directory: 'backend_test']
backend_test_smoke:
    npm run test:smoke

# install protoc-gen-dart
install_protoc_dart:
    dart pub global activate protoc_plugin

# Web 前端开发服务器 (http://localhost:5173)
[working-directory: 'frontend']
fw:
    pnpm dev

# Web 前端构建
[working-directory: 'frontend']
fb:
    pnpm build

# Web 前端安装依赖
[working-directory: 'frontend']
fi:
    pnpm install
