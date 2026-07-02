import defaultConfig from '../config/default.js';

let _config = { ...defaultConfig };

export function getConfig() {
  return _config;
}

export function setConfig(overrides) {
  _config = { ..._config, ...overrides };
}
