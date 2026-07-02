import { getProto } from './proto.js';

let ridCounter = 0;

export function nextRid() {
  ridCounter += 1;
  return `${Date.now()}${ridCounter}`;
}

export function encodePacket(cmd, payload, http = false) {
  const Packet = getProto().lookupType('entity.Packet');
  const rid = nextRid();
  const message = Packet.create({ rid, cmd, http, payload });
  return { rid, data: Packet.encode(message).finish() };
}

export function decodePacket(bytes) {
  const Packet = getProto().lookupType('entity.Packet');
  return Packet.decode(bytes);
}
