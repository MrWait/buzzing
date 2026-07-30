import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:buzzing/controller/im.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/models/idl/timer.pb.dart';
import 'package:buzzing/models/idl/setting.pb.dart';
import 'package:buzzing/page/im/location_picker.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as p;

class MessageInput extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final im = ref.watch(imProvider);
    final chatName = im.getChat(im.chatId)?.name ?? '';
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListenableBuilder(
        listenable: im,
        builder: (ctx, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 引用回复预览条
            if (im.replyTarget != null)
              _ReplyPreviewBar(im: im, cs: cs, tt: tt),
            if (im.showMentionPopup && im.mentionCandidates.isNotEmpty)
              MentionPopup(
                candidates: im.mentionCandidates.map((e) => e.name).toList(),
                layerLink: im.layerLink,
                onTap: (name) {
                  var entry = im.mentionCandidates.firstWhere(
                    (e) => e.name == name,
                    orElse: () => (id: Int64(0), name: name),
                  );
                  im.insertMention(name, mentionId: entry.id);
                },
                offset: im.popuppOffset,
              ),
            // 禁言提示
            _MuteHint(im: im),
            CompositedTransformTarget(
              link: im.layerLink,
              child: QuillEditor.basic(
                controller: im.quillController,
                focusNode: im.focusNode,
                config: QuillEditorConfig(
                  placeholder: '发送到 $chatName',
                  maxHeight: 120,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  customStyles: DefaultStyles(
                    placeHolder: DefaultTextBlockStyle(
                      tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                      const HorizontalSpacing(0, 0),
                      VerticalSpacing.zero,
                      VerticalSpacing.zero,
                      null,
                    ),
                  ),
                  embedBuilders: [
                    ...FlutterQuillEmbeds.editorBuilders(),
                    MentionEmbedBuilder(),
                  ],
                ),
              ),
            ),
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: cs.outlineVariant)),
              ),
              child: Row(
                children: [
                  _ToolbarBtn(icon: Icons.image_outlined, onTap: () => _pickImage(context, ref, im)),
                  _ToolbarBtn(icon: Icons.attach_file, onTap: () => _pickFile(context, ref, im)),
                  _ToolbarBtn(icon: Icons.emoji_emotions_outlined, onTap: () async {}),
                  _ToolbarBtn(icon: Icons.alternate_email, onTap: () async {}),
                  _ToolbarBtn(
                    icon: Icons.movie_creation_outlined,
                    onTap: () => _pickVideo(context, ref, im),
                  ),
                  _ToolbarBtn(
                    icon: Icons.mic_none,
                    onTap: () => _startVoiceRecord(context, ref, im),
                  ),
                  _ToolbarBtn(
                    icon: Icons.location_on_outlined,
                    onTap: () =>
                        _pickLocation(context, im),
                  ),
                  _ToolbarBtn(
                    icon: Icons.videocam,
                    onTap: () => _createMeetingAndShare(context, ref, im),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onLongPress: () => _showScheduleOptions(context, im),
                    child: _ToolbarBtn(
                      icon: Icons.send,
                      color: cs.primary,
                      onTap: () => im.onSendMessage(""),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImController im) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xFile == null || im.chatId == Int64(0)) return;

    final file = File(xFile.path);
    final bytes = await file.readAsBytes();
    final fileName = p.basename(xFile.path);
    final fileSize = await file.length();

    await _uploadAndSend(context, im, bytes, fileName, fileSize, MessageType.IMAGE.value);
  }

  Future<void> _pickFile(BuildContext context, WidgetRef ref, ImController im) async {
    final result = await FilePicker.pickFiles(withData: true);
    if (result == null || result.files.isEmpty || im.chatId == Int64(0)) return;

    final pf = result.files.first;
    final bytes = pf.bytes ?? await File(pf.path!).readAsBytes();
    final fileName = pf.name;
    final fileSize = pf.size;

    await _uploadAndSend(context, im, bytes, fileName, fileSize, MessageType.FILE.value);
  }

  Future<void> _pickVideo(BuildContext context, WidgetRef ref, ImController im) async {
    final picker = ImagePicker();
    final xFile = await picker.pickVideo(source: ImageSource.gallery);
    if (xFile == null || im.chatId == Int64(0)) return;

    final file = File(xFile.path);
    final bytes = await file.readAsBytes();
    final fileName = p.basename(xFile.path);
    final fileSize = await file.length();

    // TODO: extract video duration via platform channel or FFmpeg package
    await _uploadAndSend(context, im, bytes, fileName, fileSize, MessageType.MEDIA.value);
  }

  Future<void> _pickLocation(BuildContext context, ImController im) async {
    if (im.chatId == Int64(0)) return;
    final loc = await Navigator.push<LocationContent>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerPage()),
    );
    if (loc == null || context.mounted == false) return;

    final summary = loc.name.isNotEmpty ? loc.name : loc.address;
    final draftMsg = Message.create()
      ..tpy = MessageType.LOCATION.value
      ..fromId = im.userId
      ..content = loc.writeToBuffer()
      ..summary = summary
      ..chatId = im.chatId;
    final stashId = await im.preSendMessage(im.chatId, draftMsg);
    if (stashId == null) return;
    final sendMsg = Message.create()
      ..tpy = MessageType.LOCATION.value
      ..fromId = im.userId
      ..content = loc.writeToBuffer()
      ..summary = summary
      ..chatId = im.chatId;
    await im.sendMessage(stashId, sendMsg);
  }

  void _showScheduleOptions(BuildContext context, ImController im) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.send, color: cs.primary),
              title: Text('立即发送', style: tt.bodyMedium),
              onTap: () {
                Navigator.pop(ctx);
                im.onSendMessage('');
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: cs.primary),
              title: Text(t.scheduleSend, style: tt.bodyMedium),
              onTap: () {
                Navigator.pop(ctx);
                _pickScheduleTime(context, im);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickScheduleTime(BuildContext context, ImController im) async {
    if (im.chatId == Int64(0)) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked == null || context.mounted == false) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null || context.mounted == false) return;

    final sendAt = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
    final sendAtMs = sendAt.millisecondsSinceEpoch;
    if (sendAtMs <= DateTime.now().millisecondsSinceEpoch) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('定时时间必须在未来')),
        );
      }
      return;
    }

    // Build a minimal ScheduleMessageRequest and send via SDK
    final req = ScheduleMessageRequest(
      chatId: im.chatId,
      sendAtMs: Int64(sendAtMs),
      tpy: MessageType.TEXT.value,
      content: Uint8List(0), // content will be filled via SDK
      clientId: Int64(DateTime.now().microsecondsSinceEpoch),
    );
    try {
      await im.sdk.invokeAsync(Command.SCHEDULE_MESSAGE, req.writeToBuffer());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已定时于 ${time.format(context)} 发送')),
        );
      }
    } catch (e) {
      L.e("schedule message error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('定时发送失败: $e')),
        );
      }
    }
  }

  Future<void> _uploadAndSend(
    BuildContext context,
    ImController im,
    Uint8List bytes,
    String fileName,
    int fileSize,
    int msgType,
  ) async {
    final baseUrl = Config.apiUrl();
    if (baseUrl.isEmpty) {
      L.e("upload error: base url not configured");
      return;
    }

    // 非文本消息使用固定文案（content 的 altText 与 summary），不使用文件名
    const imgText = '[图片]';
    const fileText = '[文件]';
    const mediaText = '[视频]';
    final isImage = msgType == MessageType.IMAGE.value;
    final String summaryText;
    if (msgType == MessageType.IMAGE.value) {
      summaryText = imgText;
    } else if (msgType == MessageType.FILE.value) {
      summaryText = fileText;
    } else if (msgType == MessageType.MEDIA.value) {
      summaryText = mediaText;
    } else {
      summaryText = fileName;
    }

    // 1. Create draft message
    final draftContent = isImage
        ? MessageImage(altText: imgText).writeToBuffer()
        : msgType == MessageType.MEDIA.value
        ? MediaContent(mimeType: mime(fileName) ?? 'video/mp4').writeToBuffer()
        : MessageFile(name: fileName, size: Int64(fileSize)).writeToBuffer();

    final draftMsg = Message.create()
      ..tpy = msgType
      ..fromId = im.userId
      ..content = draftContent
      ..summary = summaryText
      ..chatId = im.chatId;
    final stashId = await im.preSendMessage(im.chatId, draftMsg);
    if (stashId == null) return;

    final taskKey = 'upload_task_${stashId}';

    // 2. Persist upload task via SDK setting store
    try {
      final taskReq = LocalSettingSetRequest.create()
        ..key = taskKey
        ..value = jsonEncode({
          'client_id': stashId.toInt(),
          'chat_id': im.chatId.toInt(),
          'tpy': msgType,
          'file_name': fileName,
          'file_size': fileSize,
        });
      await im.sdk.invokeAsync(Command.SETTING_SET, taskReq.writeToBuffer());
    } catch (e) {
      L.w("save upload task failed: $e");
    }

    // 3. Upload file via Dio
    try {
      final mimeType = mime(fileName) ?? 'application/octet-stream';
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName, contentType: DioMediaType.parse(mimeType)),
      });
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      final token = im.sdk.token;
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final resp = await dio.post('/api/files/upload', data: formData);

      if (resp.statusCode != 200) {
        L.e("upload failed: ${resp.statusCode}");
        return;
      }

      final fileId = int.parse(resp.data['id'].toString());
      final downloadUrl = '$baseUrl/api/files/$fileId';
      final thumbnailUrl = resp.data['thumbnail_url'] as String?;
      final width = resp.data['width'] as int? ?? 0;
      final height = resp.data['height'] as int? ?? 0;

      // 4. Update message with real URLs and send
      final content = isImage
          ? MessageImage(
              url: downloadUrl,
              thumbnailUrl: thumbnailUrl ?? '',
              width: width,
              height: height,
              altText: imgText,
            ).writeToBuffer()
          : msgType == MessageType.MEDIA.value
          ? MediaContent(
              fileId: fileId.toString(),
              url: downloadUrl,
              thumbnailUrl: thumbnailUrl ?? '',
              width: width,
              height: height,
              fileSize: Int64(fileSize),
              mimeType: mime(fileName) ?? 'video/mp4',
            ).writeToBuffer()
          : MessageFile(url: downloadUrl, name: fileName, size: Int64(fileSize)).writeToBuffer();

      final sendMsg = Message.create()
        ..tpy = msgType
        ..fromId = im.userId
        ..content = content
        ..summary = summaryText
        ..chatId = im.chatId;
      await im.sendMessage(stashId, sendMsg);

      // 5. Clean up upload task
      try {
        final cleanReq = LocalSettingSetRequest.create()
          ..key = taskKey
          ..value = '';
        await im.sdk.invokeAsync(Command.SETTING_SET, cleanReq.writeToBuffer());
      } catch (e) {
        L.w("clean upload task failed: $e");
      }
    } catch (e) {
      L.e("upload and send error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('文件发送失败: $e')),
        );
      }
    }
  }

  Future<void> _createMeetingAndShare(
      BuildContext context, WidgetRef ref, ImController im) async {
    if (im.chatId == Int64(0)) return;

    final meetingHome = ref.read(meetingHomeLogicProvider);
    final account = DataPersistence.getAccount();
    final hostName = account?.loginUser?.user.name ?? '';

    var resp = await meetingHome.createMeeting(title: '群聊会议');
    if (resp == null || !resp.hasMeeting()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建会议失败')),
        );
      }
      return;
    }

    await meetingHome.shareMeetingToChat(
      im: im,
      chatId: im.chatId,
      roomId: resp.meeting.roomId,
      title: resp.meeting.title,
      hostName: hostName,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已发送会议邀请'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  Future<void> _startVoiceRecord(
      BuildContext context, WidgetRef ref, ImController im) async {
    // TODO: add record / flutter_sound package, then integrate actual recording
    // For now, show a bottom sheet with recording UI placeholder
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.holdToRecord, style: tt.titleMedium),
              const SizedBox(height: 24),
              GestureDetector(
                onLongPressStart: (_) async {
                  // TODO: start recording via MethodChannel / flutter_sound
                  L.d('voice record started');
                },
                onLongPressEnd: (details) async {
                  // TODO: stop recording, upload, send as voice message
                  L.d('voice record ended, local=${details.localPosition}');
                  // If swipe up (dy < -100), cancel
                  if (details.localPosition.dy < -100) {
                    L.d('voice record cancelled');
                    return;
                  }
                  // Placeholder: create a dummy voice message
                  if (im.chatId == Int64(0)) return;
                  // TODO: upload recorded file, then send
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('语音录制功能待接入')),
                  );
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: cs.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mic, size: 40, color: cs.onError),
                ),
              ),
              const SizedBox(height: 16),
              Text(t.swipeUpCancel, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        );
      },
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _ToolbarBtn({required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: color ?? cs.onSurfaceVariant),
      ),
    );
  }
}

class MentionEmbedBuilder extends EmbedBuilder {
  @override
  String get key => "mention";

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final cs = Theme.of(context).colorScheme;
    final text = embedContext.node.value as String? ?? '';
    return Text(
      text,
      style: TextStyle(
        color: cs.primary,
        fontWeight: FontWeight.normal,
        backgroundColor: cs.primary.withValues(alpha: 0.1),
      ),
    );
  }
}

class _MuteHint extends ConsumerWidget {
  final ImController im;

  const _MuteHint({required this.im});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final chat = im.getChat(im.chatId);
    if (chat == null || chat.chatType != 2) return const SizedBox.shrink();

    final isOwner = im.userId == chat.ownerId;
    final isAdmin = chat.adminIds.contains(im.userId);
    if (isOwner || isAdmin) return const SizedBox.shrink();

    final now = DateTime.now().millisecondsSinceEpoch;
    final globalMuted = chat.globalMuteUntil > Int64.ZERO &&
        chat.globalMuteUntil > Int64(now);

    if (!globalMuted) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: cs.errorContainer.withValues(alpha: 0.3),
      child: Row(
        children: [
          Icon(Icons.volume_off, size: 14, color: cs.error),
          const SizedBox(width: 6),
          Text(
            '群聊已开启全员禁言',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyPreviewBar extends StatelessWidget {
  final ImController im;
  final ColorScheme cs;
  final TextTheme tt;

  const _ReplyPreviewBar({required this.im, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    final target = im.replyTarget!;
    final senderName = im.getUser(target.fromId)?.name ?? '';
    final preview = target.summary.isNotEmpty ? target.summary : '(消息已撤回)';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Container(width: 3, height: 32, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '回复 ${senderName.isNotEmpty ? senderName : "消息"}',
                  style: tt.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                ),
                Text(
                  preview,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: im.clearReply,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 16, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class MentionPopup extends StatelessWidget {
  final List<String> candidates;
  final LayerLink layerLink;
  final Offset offset;
  final Function? onTap;

  MentionPopup({
    this.onTap,
    required this.candidates,
    required this.layerLink,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: 160,
      child: Container(
        width: 160,
        child: CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: offset,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                final name = candidates[index];
                return InkWell(
                  onTap: () {
                    if (onTap != null) onTap!(name);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(name),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
