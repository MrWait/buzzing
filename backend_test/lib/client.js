import WebSocket from 'ws';
import { getConfig } from './config.js';
import { nextRid } from './packet.js';
import { getProto } from './proto.js';

export class BuzzingClient {
  constructor() {
    this._token = null;
    this._account = null;
    this._user = null;
    this._httpBase = null;
    this._wsUrl = null;
    this._unionConfig = null;
    this._ws = null;
    this._wsWaiters = new Map();
    this._wsConnected = false;
    this._pushHandler = null;
    this._heartbeatTimer = null;
  }

  get token() { return this._token; }
  get account() { return this._account; }
  get user() { return this._user; }
  get userId() { return this._user?.id; }
  get tenantId() { return this._user?.tenant_id; }
  get wsConnected() { return this._wsConnected; }

  setAuth(token, account, user) {
    this._token = token;
    this._account = account;
    this._user = user;
  }

  /** 从 Union Config 中提取 HTTP 和 WS 地址 */
  applyUnionConfig(uc) {
    this._httpBase = `${uc.gateway}:${uc.gateway_port}`;
    this._wsUrl = `${uc.ws}:${uc.ws_port}`;
    this._unionConfig = uc;
  }

  onPush(handler) {
    this._pushHandler = handler;
  }

  // ---- HTTP ----

  async httpRequest(cmd, payloadBytes) {
    const config = getConfig();
    const base = this._httpBase || config.host;
    const rid = nextRid();
    const url = `${base}/api/v1`;

    const boundary = `----FormBoundary${Date.now()}`;
    const body = buildMultipartBody(boundary, payloadBytes);

    const headers = {
      'Content-Type': `multipart/form-data; boundary=${boundary}`,
      'rid': rid.toString(),
      'cmd': cmd.toString(),
    };
    if (this._token) {
      headers['Authorization'] = `Bearer ${this._token}`;
    }

    const response = await fetch(url, {
      method: 'POST',
      headers,
      body,
    });

    const code = parseInt(response.headers.get('code') || '0', 10);
    const respRid = response.headers.get('rid') || '0';
    const data = new Uint8Array(await response.arrayBuffer());

    return { rid: BigInt(respRid), code, data };
  }

  // ---- WebSocket ----

  async connectWs() {
    if (this._wsConnected) return;

    const config = getConfig();
    if (!this._token) throw new Error('No token set. Call setAuth() or login first.');

    const wsUrl = this._wsUrl || `${config.host.replace(/^http/, 'ws').replace(/:5150$/, ':8889')}`;

    return new Promise((resolve, reject) => {
      const ws = new WebSocket(wsUrl, {
        headers: {
          'x-buzzing-token': this._token,
          'x-buzzing-appversion': config.appVersion,
          'x-buzzing-deviceid': config.deviceId,
        },
        handshakeTimeout: 10000,
        rejectUnauthorized: false,
      });

      ws.binaryType = 'nodebuffer';

      ws.on('open', () => {
        this._ws = ws;
        this._wsConnected = true;
        this._startHeartbeat();
        resolve();
      });

      ws.on('message', (data) => {
        this._handleWsMessage(data);
      });

      ws.on('error', (err) => {
        this._wsConnected = false;
        reject(err);
      });

      ws.on('close', () => {
        this._wsConnected = false;
        this._stopHeartbeat();
        this._ws = null;
        for (const [rid, waiter] of this._wsWaiters) {
          clearTimeout(waiter.timer);
          waiter.reject(new Error('WS connection closed'));
        }
        this._wsWaiters.clear();
      });
    });
  }

  async wsRequest(cmd, payloadBytes, timeout = 10000) {
    if (!this._wsConnected) throw new Error('WS not connected. Call connectWs() first.');

    const rid = nextRid();
    const Packet = getProto().lookupType('entity.Packet');
    const packet = Packet.create({ rid, cmd, payload: payloadBytes });
    const data = Packet.encode(packet).finish();

    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this._wsWaiters.delete(rid.toString());
        reject(new Error(`WS request timeout: cmd=${cmd} rid=${rid} timeout=${timeout}ms`));
      }, timeout);

      this._wsWaiters.set(rid.toString(), (response) => {
        clearTimeout(timer);
        resolve({ code: response.code, data: response.payload });
      });

      this._ws.send(data);
    });
  }

  closeWs() {
    this._stopHeartbeat();
    if (this._ws) {
      this._ws.close();
      this._ws = null;
    }
    this._wsConnected = false;
  }

  // ---- Internal ----

  _handleWsMessage(data) {
    const buf = Buffer.isBuffer(data) ? data : Buffer.from(data);
    const Packet = getProto().lookupType('entity.Packet');
    let packet;
    try {
      packet = Packet.decode(new Uint8Array(buf));
    } catch {
      return;
    }

    const ridKey = packet.rid.toString();
    const waiter = this._wsWaiters.get(ridKey);

    if (waiter) {
      this._wsWaiters.delete(ridKey);
      waiter(packet);
    } else if (this._pushHandler) {
      this._pushHandler(packet.cmd, packet.payload, packet.rid);
    }
  }

  _startHeartbeat() {
    if (this._heartbeatTimer) return;
    this._heartbeatTimer = setInterval(() => {
      if (this._ws?.readyState === WebSocket.OPEN) {
        try { this._ws.ping(); } catch {}
      }
    }, 30000);
  }

  _stopHeartbeat() {
    if (this._heartbeatTimer) {
      clearInterval(this._heartbeatTimer);
      this._heartbeatTimer = null;
    }
  }
}

function buildMultipartBody(boundary, payloadBytes) {
  const encoder = new TextEncoder();
  const header = encoder.encode(
    `--${boundary}\r\nContent-Disposition: form-data; name="data"\r\nContent-Type: application/octet-stream\r\n\r\n`
  );
  const footer = encoder.encode(`\r\n--${boundary}--\r\n`);
  const parts = [header, payloadBytes, footer];
  const totalLen = parts.reduce((s, p) => s + p.byteLength, 0);
  const result = new Uint8Array(totalLen);
  let offset = 0;
  for (const p of parts) {
    result.set(p, offset);
    offset += p.byteLength;
  }
  return result;
}
