import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/page/meeting/meeting_logic.dart';
import 'package:flutter/material.dart';

class ChatOverlay extends StatefulWidget {
  final List<ChatMessage> messages;
  final int unread;
  final bool open;
  final void Function(String text) onSend;
  final VoidCallback onToggle;
  final String myUid;

  const ChatOverlay({
    required this.messages,
    required this.unread,
    required this.open,
    required this.onSend,
    required this.onToggle,
    required this.myUid,
  });

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void didUpdateWidget(ChatOverlay old) {
    super.didUpdateWidget(old);
    if (widget.messages.length > old.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    var text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        if (widget.open)
          Expanded(
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(left: BorderSide(color: cs.outlineVariant)),
              ),
              child: Column(
                children: [
                  Container(
                    height: 44,
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(t.meetingChat, style: tt.titleSmall),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 18,
                              color: cs.onSurfaceVariant),
                          onPressed: widget.onToggle,
                          visualDensity: VisualDensity.compact,
                          tooltip: t.close,
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: cs.outlineVariant),
                  Expanded(
                    child: widget.messages.isEmpty
                        ? Center(
                            child: Text(t.noMessages,
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                          )
                        : ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.all(8),
                            itemCount: widget.messages.length,
                            itemBuilder: (context, i) {
                              var msg = widget.messages[i];
                              if (msg.type == 'system') {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    msg.text,
                                    textAlign: TextAlign.center,
                                    style: tt.bodySmall
                                        ?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                );
                              }
                              var isMe = msg.from == widget.myUid;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Text(
                                        msg.name ?? msg.from ?? '',
                                        style: tt.labelSmall
                                            ?.copyWith(color: cs.primary),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? cs.primaryContainer
                                            : cs.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        msg.text,
                                        style: tt.bodySmall?.copyWith(
                                          color: isMe
                                              ? cs.onPrimaryContainer
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Divider(height: 1, color: cs.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: TextField(
                              controller: _controller,
                              style: tt.bodySmall,
                              decoration: InputDecoration(
                                hintText: t.chatPlaceholder,
                                hintStyle: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide:
                                      BorderSide(color: cs.outlineVariant),
                                ),
                                isDense: true,
                              ),
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(Icons.send, size: 18, color: cs.primary),
                          onPressed: _send,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
