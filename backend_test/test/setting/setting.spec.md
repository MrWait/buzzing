# setting — 设置读写

## 测试目标

验证用户设置的读取和更新功能。设置以 key-value 形式存储，按 type 分类。

## 测试用例

### 1. should get all settings

- **命令**: `SETTING_GET_ALL` (1055)
- **请求**: `GetAllSettingsRequest {}`
- **预期**: 返回码为 0
- **⚠️ 已知问题**: 服务端返回 JSON `{"error":"Bad Request"}` 而非 protobuf `GetAllSettingsResponse`

### 2. should get setting by type

- **命令**: `SETTING_GET_BY_TYPE` (1053)
- **请求**: `GetSettingByTypeRequest { type=1 }` (type=1 = SETTING_FAVORITE)
- **预期**: 返回码为 0
- **⚠️ 已知问题**: 服务端返回 JSON `{"error":"Bad Request"}` 而非 protobuf `GetSettingByTypeResponse`

### 3. should update setting by type

- **命令**: `SETTING_UPDATE` (1056)
- **请求**: `UpdateSettingRequest { type=1, value=JSON bytes }`
- **预期**: 返回成功（code=0）

### 4. should read back updated setting

- **命令**: `SETTING_GET_BY_TYPE` (1053)
- **流程**: 先更新设置，再查询同一 type
- **预期**: 返回码为 0
- **⚠️ 已知问题**: 同用例 2，服务端返回 JSON 错误

## 约束

- 仅测试 type=1（SETTING_FAVORITE）
- 更新操作已确认可用，查询操作等待服务端修复
