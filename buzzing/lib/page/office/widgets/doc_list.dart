import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/i18n/strings.g.dart';
import '../office_logic.dart';

class DocList extends ConsumerWidget {
  final OfficeLogic ctl;

  const DocList({super.key, required this.ctl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: ctl,
      builder: (context, _) {
        final state = ctl.state;
        if (state.selectedSpaceId == null) {
          return Center(
            child: Text(t.noSpaces, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          );
        }
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.spaces.firstWhere((s) => int.parse(s['id']) == state.selectedSpaceId)['name'] as String,
                      style: tt.titleSmall,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                    child: TextButton.icon(
                      onPressed: () => _newDoc(context),
                      icon: const Icon(Icons.add, size: 14),
                      label: Text(t.newDoc, style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: state.loading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : state.docs.isEmpty
                      ? Center(
                          child: Text(t.emptyDocs, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: state.docs.length,
                          itemBuilder: (ctx, index) {
                            final doc = state.docs[index];
                            final id = int.parse(doc['id']);
                            final title = doc['title'] as String;
                            final updatedAt = doc['updated_at'] as String? ?? '';
                            return _DocItem(
                              id: id,
                              title: title,
                              updatedAt: _formatDate(updatedAt),
                              onTap: () => _openDoc(context, id, title),
                              onDelete: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(t.deleteConfirm),
                                    content: Text('${t.deleteDoc}: $title'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.delete)),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  ctl.deleteDoc(id);
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  void _newDoc(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.newDoc),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: t.docTitle),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ctl.createDoc(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: Text(t.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _openDoc(BuildContext context, int id, String title) async {
    if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) return;
    try {
      final editUrl = await ctl.getEditUrl(id);
      final uri = Uri.parse('${Config.apiUrl()}$editUrl');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

class _DocItem extends StatelessWidget {
  final int id;
  final String title;
  final String updatedAt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DocItem({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.description_outlined, color: cs.primary),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: updatedAt.isNotEmpty
          ? Text(updatedAt, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))
          : null,
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, size: 18, color: cs.onSurfaceVariant),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
