# 服务端 DB 重置
dr:
    cd backend/base && cargo loco db reset

# 服务端 DB 迁移
dm:
    cd backend/base && cargo loco db migrate

# 服务端通过 DB 生成 entities 代码
de:
    cd backend/base && cargo loco db entities

# 服务端启动
ss:
    cd backend/base && cargo loco start

# 客户端在 macos 平台启动
csm:
    cd buzzing && flutter run -d macos

# 客户端在 windows 平台启动
csw:
    cd buzzing && flutter run -d windows

# 客户端在 macos 平台构建
cbm:
    cd buzzing && flutter build macos

# 客户端生成 protobuf 的 idl
cidl:
    cd buzzing && python3 util.py -c idl -t dart -s ../proto -o ./lib/models/idl/

# 客户端生成 debug 模式 SDK
clib:
    cd buzzing && python3 util.py -c lib -t debug -i ../sdk

# 客户端生成 release 模式 SDK
cdeploy:
    cd buzzing && python3 util.py -c lib -t release -i ../sdk

# 客户端构建。不建议使用
cbuild:
    cd buzzing && python3 util.py -c build

# 未知
cjson:
    cd buzzing && flutter packages pub run build_runner build

# 初始化用户数据（账户、租户、部门）。默认 init.json，可用 -s 指定文件
init_data:
    cd utils && NODE_TLS_REJECT_UNAUTHORIZED=0 node init.js

# 使用测试租户数据初始化
init_data_test:
    cd utils && NODE_TLS_REJECT_UNAUTHORIZED=0 node init.js -s ./init_test.json

# 修复 macos 端 pod 版本问题
client_macos_fix_pod:
    cd buzzing/macos && export LANG=en_US.UTF-8 && export LC_ALL=en_US.UTF-8 && pod install --repo-update

# 客户端生成多语言代码
client_gen_slang:
    cd buzzing && dart run slang

# SDK 集成测试 (编译 Rust 库 + 运行 dart 测试)
sdk_test:
    cd buzzing/sdk_test && bash run.sh

# 后端业务测试 (需要服务端运行中)
backend_test:
    cd backend_test && npm run test:business

# 后端 smoke 测试 (连通性 + 登录流程)
backend_test_smoke:
    cd backend_test && npm run test:smoke
