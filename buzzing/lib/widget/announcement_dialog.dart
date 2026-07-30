import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

/// 解析公告标题（AnnouncementContent.title，缺省回退 summary）
String announcementTitle(Message announcement) {
  try {
    final content = AnnouncementContent.fromBuffer(announcement.content);
    if (content.title.isNotEmpty) return content.title;
  } catch (_) {}
  return announcement.summary;
}

/// 解析公告正文文本（AnnouncementContent.body）
String announcementBodyText(Message announcement) {
  try {
    final content = AnnouncementContent.fromBuffer(announcement.content);
    return String.fromCharCodes(content.body);
  } catch (_) {
    return String.fromCharCodes(announcement.content);
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

/// 查看公告详情（弹窗）：标题 + 发布人/时间 + 正文全文
void showAnnouncementViewer(BuildContext context, Message announcement,
    {ImController? im}) {
  final title =
      announcementTitle(announcement).isNotEmpty ? announcementTitle(announcement) : '群公告';
  final publisher = im?.getUser(announcement.fromId)?.name ?? '';
  final time = _formatTime(announcement.createTimeMs);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (publisher.isNotEmpty || time.isNotEmpty) ...[
              Text(
                [
                  if (publisher.isNotEmpty) '发布人：$publisher',
                  if (time.isNotEmpty) '发布于：$time',
                ].join('  '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              announcementBodyText(announcement),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
      ],
    ),
  );
}

/// 编辑公告（弹窗），返回是否保存
Future<bool?> showAnnouncementEditor(
  BuildContext context,
  ImController im,
  Int64 chatId,
  Message? announcement,
) async {
  final titleCtrl = TextEditingController(
      text: announcement == null ? '' : announcementTitle(announcement));
  final bodyCtrl = TextEditingController(
      text: announcement == null ? '' : announcementBodyText(announcement));
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('群公告'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleCtrl,
            decoration:
                const InputDecoration(labelText: '标题', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bodyCtrl,
            decoration:
                const InputDecoration(labelText: '内容', border: OutlineInputBorder()),
            maxLines: 5,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () async {
            final title = titleCtrl.text.trim();
            final body = bodyCtrl.text;
            if (title.isEmpty && body.isEmpty) {
              if (ctx.mounted) Navigator.pop(ctx, false);
              return;
            }
            await im.setAnnouncement(chatId, title, 0, body.codeUnits, title);
            if (ctx.mounted) Navigator.pop(ctx, true);
          },
          child: const Text('保存'),
        ),
      ],
    ),
  );
}
