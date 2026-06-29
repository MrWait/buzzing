import 'dart:io';

import 'package:buzzing/utils/screencapture_pc.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/widget/button.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_macos_permissions/flutter_macos_permissions.dart';

class MessageInput extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final im = ref.watch(imProvider);
    return Container(
      height: 150,
      child: ListenableBuilder(
        listenable: im,
        builder: (ctx, _) => Scaffold(
          floatingActionButton: im.showMentionPopup
              ? MentionPopup(
                  candidates: im.candidates,
                  layerLink: im.layerLink,
                  onTap: im.insertMention,
                  offset: im.popuppOffset,
                )
              : null,
          body: Column(
            children: [
              CompositedTransformTarget(
                link: im.layerLink,
                child: QuillEditor.basic(
                  controller: im.quillController,
                  config: QuillEditorConfig(
                    minHeight: 100,
                    maxHeight: 100,
                    embedBuilders: [
                      ...FlutterQuillEmbeds.editorBuilders(),
                      MentionEmbedBuilder(),
                    ],
                  ),
                ),
              ),
              Container(
                height: 32,
                child: Row(
                  spacing: 4,
                  children: [
                    Expanded(
                      child: QuillSimpleToolbar(
                        controller: im.quillController,
                        config: QuillSimpleToolbarConfig(
                          showRedo: false,
                          showUndo: false,
                          multiRowsDisplay: false,
                          embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                        ),
                      ),
                    ),
                    Container(width: 50),
                    Button(
                      enabled: true,
                      text: "SC",
                      textStyle: PageStyle.ts_171A1D_17,
                      onTap: () async {
                        if (Platform.isMacOS) {
                          var granted =
                              await FlutterMacosPermissions.requestScreenRecording();
                        }
                        await captureScreen(null);
                      },
                    ),
                    Button(
                      enabled: true,
                      text: "E",
                      textStyle: PageStyle.ts_171A1D_17,
                      onTap: () async {},
                    ),
                    Button(
                      enabled: true,
                      text: "@",
                      textStyle: PageStyle.ts_171A1D_17,
                      onTap: () async {
                      },
                    ),
                    Button(
                      enabled: true,
                      text: "C",
                      textStyle: PageStyle.ts_171A1D_17,
                      onTap: () async {},
                    ),
                    Button(
                      enabled: true,
                      text: "+",
                      textStyle: PageStyle.ts_171A1D_17,
                      onTap: () async {},
                    ),
                    Button(
                      enabled: true,
                      text: "P",
                      textStyle: PageStyle.ts_171A1D_17,
                      onTap: () async {},
                    ),
                    Button(
                      enabled: true,
                      text: "Send",
                      textStyle: PageStyle.ts_171A1D_17,
                      onTap: () {
                        im.onSendMessage("");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MentionEmbedBuilder extends EmbedBuilder {
  @override
  String get key => "mention";

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final text = embedContext.node.value as String? ?? '';
    return Text(
      text,
      style: TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.normal,
        backgroundColor: Colors.blue.withOpacity(0.1),
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
                return ListTile(
                  title: Text(name),
                  onTap: () {
                    if (onTap != null) onTap!(name);
                  },
                  hoverColor: PageStyle.c_898989,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
