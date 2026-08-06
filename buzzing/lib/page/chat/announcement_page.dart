import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/widget/announcement_dialog.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 群公告查看/编辑覆盖层。
///
/// 覆盖整个消息列表区域（含消息输入框），以支持更复杂的公告编辑。
/// 桌面端作为聊天区的全幅覆盖层，移动端可作为整页路由。
class AnnouncementPage extends ConsumerStatefulWidget {
  final Int64 chatId;
  final VoidCallback? onClose;

  const AnnouncementPage({super.key, required this.chatId, this.onClose});

  @override
  ConsumerState<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends ConsumerState<AnnouncementPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final im = ref.read(imProvider);
    final chat = im.getChat(widget.chatId);
    final announcement = _currentAnnouncement(im);
    _titleCtrl = TextEditingController(
      text: announcement == null ? '' : _title(announcement),
    );
    _bodyCtrl = TextEditingController(
      text: announcement == null ? '' : _body(announcement),
    );
    // 管理员/群主直接进入编辑模式，普通成员进入查看模式
    _editing = (chat?.ownerId == im.userId ||
        (chat?.adminIds.contains(im.userId) ?? false));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Message? _currentAnnouncement(ImController im) {
    final announcement = im.entity.messages[widget.chatId];
    if (announcement == null ||
        announcement.tpy != MessageType.ANNOUNCEMENT.value ||
        announcement.status == EntityStatus.DELETED.value) {
      return null;
    }
    return announcement;
  }

  String _title(Message announcement) => announcementTitle(announcement);
  String _body(Message announcement) => announcementBodyText(announcement);

  void _close() {
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose();
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text;
    if (title.isEmpty && body.isEmpty) return;
    setState(() => _saving = true);
    await ref.read(imProvider).setAnnouncement(widget.chatId, title, 0, body.codeUnits, title);
    if (mounted) {
      setState(() {
        _saving = false;
        _editing = false;
      });
    }
  }

  Future<void> _delete() async {
    await ref.read(imProvider).deleteAnnouncement(widget.chatId);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final im = ref.watch(imProvider);
    final chat = im.getChat(widget.chatId);
    final announcement = _currentAnnouncement(im);
    final canEdit = chat != null &&
        (chat.ownerId == im.userId || chat.adminIds.contains(im.userId));

    final hasAnnouncement = announcement != null;
    return Material(
      color: cs.surface,
      child: Column(
        children: [
          // 覆盖层头部：返回 + 标题 + 操作图标（编辑/保存/删除）+ 关闭
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Row(
              children: [
                if (_editing)
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 20, color: cs.onSurfaceVariant),
                    tooltip: '返回',
                    onPressed: _saving ? null : () => setState(() => _editing = false),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                const SizedBox(width: 4),
                Text('群公告', style: tt.titleMedium),
                const Spacer(),
                if (_editing) ...[
                  // 编辑页：保存、删除放在关闭按钮左侧
                  IconButton(
                    icon: Icon(Icons.check, size: 20, color: cs.primary),
                    tooltip: '保存',
                    onPressed: _saving ? null : _save,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  if (hasAnnouncement)
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: cs.error),
                      tooltip: '删除',
                      onPressed: _saving ? null : _confirmDelete,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                ] else if (canEdit) ...[
                  // 查看页：编辑按钮改为 edit 图标，放在关闭按钮左侧
                  IconButton(
                    icon: Icon(
                      hasAnnouncement ? Icons.edit_outlined : Icons.campaign_outlined,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                    tooltip: hasAnnouncement ? '编辑' : '设置公告',
                    onPressed: () => setState(() => _editing = true),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: cs.onSurfaceVariant),
                  tooltip: '关闭',
                  onPressed: _close,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          Expanded(
            child: _editing
                ? _buildEditor(cs, tt)
                : _buildViewer(cs, tt, im, chat, announcement, canEdit),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: '标题', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _bodyCtrl,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                labelText: '内容',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewer(
    ColorScheme cs,
    TextTheme tt,
    ImController im,
    Chat? chat,
    Message? announcement,
    bool canEdit,
  ) {
    if (announcement == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined, size: 40, color: cs.onSurfaceVariant),
            const SizedBox(height: 8),
            Text('暂无公告', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    final title = _title(announcement);
    final publisher = im.getUser(announcement.fromId)?.name ?? '';
    final time = _formatTime(announcement.createTimeMs);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.isNotEmpty ? title : '群公告',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (publisher.isNotEmpty || time.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              [if (publisher.isNotEmpty) '发布人：$publisher', if (time.isNotEmpty) '发布于：$time'].join('  '),
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 16),
          Text(_body(announcement), style: tt.bodyMedium),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除公告'),
        content: const Text('确定要删除该群公告吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('删除', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _delete();
      if (mounted) setState(() {});
    }
  }

  String _formatTime(Int64 ms) {
    if (ms <= Int64.ZERO) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms.toInt());
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${two(dt.hour)}:${two(dt.minute)}';
    }
    return '${dt.month}/${dt.day} ${two(dt.hour)}:${two(dt.minute)}';
  }
}