import protobuf from 'protobufjs'
import entityProto from '../../../../proto/entity.proto?raw'
import commandProto from '../../../../proto/command.proto?raw'
import chatProto from '../../../../proto/chat.proto?raw'
import messageProto from '../../../../proto/message.proto?raw'
import feedProto from '../../../../proto/feed.proto?raw'
import gatewayProto from '../../../../proto/gateway.proto?raw'
import deptProto from '../../../../proto/dept.proto?raw'
import userProto from '../../../../proto/user.proto?raw'
import presenceProto from '../../../../proto/presence.proto?raw'
import typingProto from '../../../../proto/typing.proto?raw'
import threadProto from '../../../../proto/thread.proto?raw'
import officeProto from '../../../../proto/office.proto?raw'
import muteProto from '../../../../proto/mute.proto?raw'
import inviteProto from '../../../../proto/invite.proto?raw'
import joinRequestProto from '../../../../proto/join_request.proto?raw'
import pinProto from '../../../../proto/pin.proto?raw'
import searchProto from '../../../../proto/search.proto?raw'
import translateProto from '../../../../proto/translate.proto?raw'

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
    { name: 'dept.proto', content: deptProto },
    { name: 'user.proto', content: userProto },
    { name: 'presence.proto', content: presenceProto },
    { name: 'typing.proto', content: typingProto },
    { name: 'thread.proto', content: threadProto },
    { name: 'office.proto', content: officeProto },
    { name: 'mute.proto', content: muteProto },
    { name: 'invite.proto', content: inviteProto },
    { name: 'join_request.proto', content: joinRequestProto },
    { name: 'pin.proto', content: pinProto },
    { name: 'search.proto', content: searchProto },
    { name: 'translate.proto', content: translateProto },
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
