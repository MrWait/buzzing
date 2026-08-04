import protobuf from 'protobufjs';
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROTO_DIR = resolve(__dirname, '../../proto');

let _root = null;

function loadProtoFile(filename) {
  const path = resolve(PROTO_DIR, filename);
  return readFileSync(path, 'utf-8');
}

export async function initProto() {
  if (_root) return _root;

  const root = new protobuf.Root();

  const files = [
    'entity.proto',
    'command.proto',
    'error.proto',
    'user.proto',
    'chat.proto',
    'message.proto',
    'feed.proto',
    'gateway.proto',
    'sdk.proto',
    'setting.proto',
    'dept.proto',
    'calendar.proto',
    'server.proto',
    'pipeline.proto',
  ];

  for (const file of files) {
    const content = loadProtoFile(file);
    const parsed = protobuf.parse(content, { keepCase: true });
    // parsed.root contains a single child namespace named after the package
    for (const child of parsed.root.nestedArray) {
      root.add(child);
    }
  }

  root.resolveAll();
  _root = root;
  return root;
}

export function getProto() {
  if (!_root) throw new Error('proto not initialized, call initProto() first');
  return _root;
}
