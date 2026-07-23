import protobuf from 'protobufjs'
import entityProto from '../../../../proto/entity.proto?raw'
import commandProto from '../../../../proto/command.proto?raw'
import chatProto from '../../../../proto/chat.proto?raw'
import messageProto from '../../../../proto/message.proto?raw'
import feedProto from '../../../../proto/feed.proto?raw'
import gatewayProto from '../../../../proto/gateway.proto?raw'
import presenceProto from '../../../../proto/presence.proto?raw'
import typingProto from '../../../../proto/typing.proto?raw'
import threadProto from '../../../../proto/thread.proto?raw'

let protoRoot: protobuf.Root | null = null

export function getProto(): protobuf.Root {
  if (protoRoot) return protoRoot
  const root = new protobuf.Root()
  const files = [
    { name: 'entity.proto', content: entityProto },
    { name: 'command.proto', content: commandProto },
    { name: 'chat.proto', content: chatProto },
    { name: 'message.proto', content: messageProto },
    { name: 'feed.proto', content: feedProto },
    { name: 'gateway.proto', content: gatewayProto },
    { name: 'presence.proto', content: presenceProto },
    { name: 'typing.proto', content: typingProto },
    { name: 'thread.proto', content: threadProto },
  ]
  for (const { content } of files) {
    const parsed = protobuf.parse(content, { keepCase: true })
    for (const child of parsed.root.nestedArray) {
      root.add(child)
    }
  }
  root.resolveAll()
  protoRoot = root
  return root
}

export function lookup(typeName: string): protobuf.Type {
  return getProto().lookupType(typeName)
}

export function encode(typeName: string, data: Record<string, any>): Uint8Array {
  const type = lookup(typeName)
  return type.encode(type.create(data)).finish() as Uint8Array
}

export function decode(typeName: string, data: Uint8Array): any {
  const type = lookup(typeName)
  return type.decode(data)
}

let ridCounter = 0
export function nextRid(): string {
  ridCounter += 1
  return `${Date.now()}${ridCounter}`
}
