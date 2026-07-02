import 'dart:io';

import 'package:buzzing/utils/screencapture_pc.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_macos_permissions/flutter_macos_permissions.dart';

class MessageInput extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final im = ref.watch(imProvider);
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: ListenableBuilder(
        listenable: im,
        builder: (ctx, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (im.showMentionPopup)
              MentionPopup(
                candidates: im.candidates,
                layerLink: im.layerLink,
                onTap: im.insertMention,
                offset: im.popuppOffset,
              ),
            CompositedTransformTarget(
              link: im.layerLink,
              child: QuillEditor.basic(
                controller: im.quillController,
                config: QuillEditorConfig(
                  minHeight: 80,
                  maxHeight: 120,
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
              child: Row(
                children: [
                  _ToolbarBtn(icon: Icons.attach_file, onTap: () async {}),
                  _ToolbarBtn(icon: Icons.emoji_emotions_outlined, onTap: () async {}),
                  _ToolbarBtn(icon: Icons.alternate_email, onTap: () async {}),
                  const Spacer(),
                  _ToolbarBtn(
                    icon: Icons.send,
                    color: cs.primary,
                    onTap: () => im.onSendMessage(""),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
