export default {
  // 仅用于下载 Union Config (GET /config/client)
  host: process.env.BUZZING_HOST || 'https://www.buzzing-im.com:5150',

  // 测试账号
  phone: process.env.BUZZING_PHONE || '10111110001',
  password: process.env.BUZZING_PASSWORD || '123456',

  // 设备信息
  appVersion: '0.1.0',
  deviceId: 'backend-test-device',
};
