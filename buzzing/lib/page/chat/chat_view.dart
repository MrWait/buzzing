import 'package:buzzing/models/const.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/widget/message_input.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    final im = ref.watch(imProvider);
    return Container(
      color: bt.mentionBg,
      child: ListenableBuilder(
        listenable: im,
        builder: (ctx, _) {
          var chatId = im.chatId;
          var chat = im.getChat(chatId);
          if (chatId == 0) {
            return Center(
              child: Text(
                '选择一个会话开始聊天',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return Column(
            children: [
              _ChatHeader(chat: chat, chatId: chatId),
              Expanded(child: MessageView()),
              MessageInput(),
            ],
          );
        },
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final dynamic chat;
  final Int64 chatId;

  const _ChatHeader({required this.chat, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    var name = '';
    if (chat != null) {
      name = chat.name;
    }
    if (name.length > 40) name = '${name.substring(0, 40)}...';

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: tt.bodySmall?.copyWith(color: cs.onPrimary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name, style: tt.titleSmall),
          ),
          IconButton(
            icon: Icon(Icons.search, size: 20, color: cs.onSurfaceVariant),
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          if (chat != null && chat.chatType == 2) ...[
            IconButton(
              icon: Icon(Icons.more_horiz, size: 20, color: cs.onSurfaceVariant),
              onPressed: () {
                context.push('${AppRoute.GROUP_PROFILE}/$chatId');
              },
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ],
      ),
    );
  }
}

class MessageView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final im = ref.watch(imProvider);
    return ListenableBuilder(
      listenable: im,
      builder: (ctx, _) {
        L.d("rebuild message view, count: ${im.messagePosList.length}");
        return Container(
          color: cs.surface,
          child: SelectionArea(
            child: ListView.builder(
              controller: im.msgCtrl,
              itemCount: im.messagePosList.length,
              itemBuilder: (context, index) {
                var msg = im.messagePosList[index];
                return Model.messageBox(msg.id, msg.fromId, im.entity);
              },
            ),
          ),
        );
      },
    );
  }
}
