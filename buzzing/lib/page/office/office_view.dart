import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/provider/office_provider.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/mobile_drawer.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'office_logic.dart';
import 'widgets/space_tree.dart';
import 'widgets/doc_list.dart';

class OfficePage extends ConsumerWidget {
  const OfficePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isMobile) {
      return const _OfficeMobile();
    }
    return const _OfficeDesktop();
  }
}

/// Desktop: original double-column layout
class _OfficeDesktop extends ConsumerWidget {
  const _OfficeDesktop();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = ref.watch(officeLogicProvider);

    return Scaffold(
      body: Row(
        children: [
          NaviBar(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(child: HeaderBarWindows()),
                Expanded(
                  child: Row(
                    children: [
                      SpaceTree(ctl: ctl),
                      Expanded(child: DocList(ctl: ctl)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mobile: full-screen space list, tapping space shows docs inline
class _OfficeMobile extends ConsumerWidget {
  const _OfficeMobile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ctl = ref.watch(officeLogicProvider);
    final im = ref.watch(imProvider);
    final user = im.loginUser.user;
    final avatarUrl = CommonUtils.fixResourceUrl(user.avatar);
    final userName = user.name.isNotEmpty ? user.name : "?";

    final drawer = buildMobileDrawer(context, ref);

    return Scaffold(
      drawer: drawer,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: cs.outlineVariant, width: 0.5),
                ),
              ),
              child: GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(avatarUrl)
                          : null,
                      child: avatarUrl.isEmpty
                          ? Text(userName[0], style: tt.bodySmall)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(t.office, style: tt.titleSmall),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: ctl,
                builder: (ctx, _) {
                  final state = ctl.state;
                  return Column(
                    children: [
                      // Spaces list
                      Expanded(
                        flex: state.selectedSpaceId != null ? 1 : 1,
                        child: _SpaceListMobile(ctl: ctl),
                      ),
                      // Docs list when space selected
                      if (state.selectedSpaceId != null) ...[
                        Divider(height: 1, color: cs.outlineVariant),
                        Expanded(
                          flex: 2,
                          child: DocList(ctl: ctl),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact space list for mobile (without fixed 220px width)
class _SpaceListMobile extends ConsumerWidget {
  final OfficeLogic ctl;

  const _SpaceListMobile({required this.ctl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: ctl,
      builder: (context, _) {
        final state = ctl.state;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text(t.office, style: tt.titleSmall),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      final controller = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(t.newSpace),
                          content: TextField(
                            controller: controller,
                            autofocus: true,
                            decoration: InputDecoration(hintText: t.spaceNameHint),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
                            TextButton(
                              onPressed: () {
                                if (controller.text.isNotEmpty) {
                                  ctl.createSpace(controller.text);
                                  Navigator.pop(ctx);
                                }
                              },
                              child: Text(t.confirm),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(t.addSpace, style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: state.loading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : state.spaces.isEmpty
                      ? Center(child: Text(t.noSpaces, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)))
                      : ListView.builder(
                          itemCount: state.spaces.length,
                          itemBuilder: (ctx, index) {
                            final space = state.spaces[index];
                            final id = int.parse(space['id']);
                            final name = space['name'] as String;
                            final selected = state.selectedSpaceId == id;
                            return ListTile(
                              dense: true,
                              selected: selected,
                              selectedTileColor: cs.primaryContainer,
                              leading: Icon(Icons.folder_outlined, size: 18, color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                              title: Text(name, style: TextStyle(fontSize: 14, color: selected ? cs.onPrimaryContainer : null)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline, size: 16, color: cs.onSurfaceVariant),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(t.deleteConfirm),
                                      content: Text('${t.deleteSpace}: $name'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.delete)),
                                      ],
                                    ),
                                  );
                                  if (ok == true) ctl.deleteSpace(id);
                                },
                              ),
                              onTap: () => ctl.selectSpace(id),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}
