import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

/// 转发选择器对话框
class ForwardPickerDialog extends StatefulWidget {
  final ImController im;
  final List<Int64> initialMessageIds;
  final Int64 sourceChatId;

  const ForwardPickerDialog({
    required this.im,
    required this.initialMessageIds,
    required this.sourceChatId,
  });

  @override
  _ForwardPickerDialogState createState() => _ForwardPickerDialogState();
}

class _ForwardPickerDialogState extends State<ForwardPickerDialog> {
  Int64? _selectedChatId;
  var _forwardType = 0; // 0=single, 1=merged
  final _selectedIds = <Int64>[];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.initialMessageIds);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Chat> get _chatList {
    final chats = widget.im.entity.chats.values.where((c) => c.id != widget.sourceChatId).toList();
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return chats;
    return chats.where((c) => c.name.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final im = widget.im;

    return AlertDialog(
      title: const Text('转发消息'),
      content: SizedBox(
        width: 440,
        height: 440,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 转发类型
            Row(children: [
              Text('转发方式: ', style: tt.bodySmall),
              const SizedBox(width: 8),
              _buildChip('逐条转发', 0),
              const SizedBox(width: 8),
              _buildChip('合并转发', 1),
            ]),
            const SizedBox(height: 12),
            // 已选消息预览
            Text('已选 ${_selectedIds.length} 条消息', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            SizedBox(
              height: 80,
              child: _selectedIds.isEmpty
                  ? Center(child: Text('未选择消息', style: tt.bodySmall))
                  : ListView.separated(
                      itemCount: _selectedIds.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final msg = im.entity.messages[_selectedIds[i]];
                        if (msg == null) return const SizedBox.shrink();
                        final user = im.getUser(msg.fromId);
                        final name = user?.name ?? '用户${msg.fromId}';
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.message_outlined, size: 16, color: cs.primary),
                          title: Text(
                            '$name: ${msg.summary}',
                            style: tt.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            // 目标会话搜索
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索会话...',
                prefixIcon: Icon(Icons.search, size: 18),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            // 会话列表
            Expanded(
              child: _chatList.isEmpty
                  ? Center(child: Text('无可用会话', style: tt.bodySmall))
                  : ListView.separated(
                      itemCount: _chatList.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final chat = _chatList[i];
                        final isSelected = chat.id == _selectedChatId;
                        return ListTile(
                          dense: true,
                          selected: isSelected,
                          selectedTileColor: cs.primaryContainer.withValues(alpha: 0.3),
                          leading: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                              style: tt.bodySmall?.copyWith(color: cs.onPrimary),
                            ),
                          ),
                          title: Text(chat.name, style: tt.bodySmall),
                          subtitle: chat.chatType == ChatType.CHAT_GROUP.value
                              ? Text('群聊', style: tt.labelSmall)
                              : Text('单聊', style: tt.labelSmall),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: cs.primary, size: 20)
                              : null,
                          onTap: () => setState(() => _selectedChatId = chat.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _selectedChatId == null || _selectedIds.isEmpty
              ? null
              : () => _doForward(context, im),
          child: const Text('转发'),
        ),
      ],
    );
  }

  Widget _buildChip(String label, int type) {
    final cs = Theme.of(context).colorScheme;
    final selected = _forwardType == type;
    return GestureDetector(
      onTap: () => setState(() => _forwardType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? cs.primary : cs.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Future<void> _doForward(BuildContext context, ImController im) async {
    L.d("forward messages: ${_selectedIds} to chat ${_selectedChatId}, type=${_forwardType}");
    Navigator.pop(context);
    im.forwardMessage(
      _selectedChatId!,
      widget.sourceChatId,
      _selectedIds,
      forwardType: _forwardType,
    );
  }
}
