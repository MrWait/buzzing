import 'dart:io';

import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/widget/user_list_item.dart';
import 'package:dio/dio.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as p;

/// 群信息编辑页（移动端整页展示）
class GroupEditPage extends StatelessWidget {
  final Int64 chatId;

  const GroupEditPage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('群信息')),
      body: GroupEditView(chatId: chatId),
    );
  }
}

/// 群信息编辑内容区：移动端作为整页，桌面端嵌入群资料面板作为二级页面
class GroupEditView extends ConsumerStatefulWidget {
  final Int64 chatId;

  const GroupEditView({super.key, required this.chatId});

  @override
  GroupEditViewState createState() => GroupEditViewState();
}

class GroupEditViewState extends ConsumerState<GroupEditView> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late String _avatar;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final chat = ref.read(imProvider).getChat(widget.chatId);
    _nameCtrl = TextEditingController(text: chat?.name ?? '');
    _descCtrl = TextEditingController(text: chat?.description ?? '');
    _avatar = chat?.avatar ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final xFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xFile == null) return;

    final file = File(xFile.path);
    final bytes = await file.readAsBytes();
    final fileName = p.basename(xFile.path);

    final baseUrl = Config.apiUrl();
    if (baseUrl.isEmpty) return;

    try {
      final mimeType = mime(fileName) ?? 'image/jpeg';
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes,
            filename: fileName, contentType: DioMediaType.parse(mimeType)),
      });
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      final token = ref.read(imProvider).sdk.token;
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final resp = await dio.post('/api/files/upload', data: formData);

      if (resp.statusCode != 200) {
        L.e("avatar upload failed: ${resp.statusCode}");
        return;
      }

      final fileId = int.parse(resp.data['id'].toString());
      final downloadUrl = '$baseUrl/api/files/$fileId';
      if (mounted) setState(() => _avatar = downloadUrl);
    } catch (e) {
      L.e("avatar upload error: $e");
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('群名称不能为空')),
      );
      return;
    }
    setState(() => _saving = true);
    final im = ref.read(imProvider);
    await im.updateChat(widget.chatId, name: name, description: _descCtrl.text.trim(), avatar: _avatar);
    if (mounted) {
      setState(() => _saving = false);
      // 窗口中间弹出成功提示（绿色 ✅ + 文案），替换底部 SnackBar
      EasyLoading.showSuccess('已保存');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final im = ref.watch(imProvider);
    final chat = im.getChat(widget.chatId);
    final canEdit = im.userId == chat?.ownerId ||
        (chat?.adminIds.contains(im.userId) ?? false);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 头像
        Center(
          child: GestureDetector(
            onTap: canEdit ? _pickAndUploadAvatar : null,
            child: Stack(
              children: [
                UserAvatar(name: _nameCtrl.text, avatar: _avatar, size: 72),
                if (canEdit)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, size: 12, color: cs.onPrimary),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameCtrl,
          enabled: canEdit,
          decoration: InputDecoration(
            labelText: '群名称',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descCtrl,
          enabled: canEdit,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: '群简介',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 24),
        if (canEdit)
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '保存中...' : '保存'),
          ),
        const SizedBox(height: 16),
        Text(
          '可在此编辑群名称与群简介，普通成员仅可查看。',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
