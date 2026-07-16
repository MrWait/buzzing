import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/i18n/strings.g.dart';
import '../office_logic.dart';

class SpaceTree extends ConsumerWidget {
  final OfficeLogic ctl;

  const SpaceTree({super.key, required this.ctl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: ctl,
      builder: (context, _) {
        final state = ctl.state;
        return Container(
          width: 220,
          color: cs.surfaceVariant,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SizedBox(
                  height: 24,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(t.office, style: tt.titleSmall),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: state.loading
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: state.spaces.length + 1,
                        itemBuilder: (ctx, index) {
                          if (index == 0) {
                            return _AddSpaceButton(ctl: ctl, cs: cs, tt: tt);
                          }
                          final space = state.spaces[index - 1];
                          final id = int.parse(space['id']);
                          final name = space['name'] as String;
                          final selected = state.selectedSpaceId == id;
                          return _SpaceItem(
                            id: id,
                            name: name,
                            selected: selected,
                            onTap: () => ctl.selectSpace(id),
                            onDelete: () async {
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
                              if (ok == true) {
                                ctl.deleteSpace(id);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SpaceItem extends StatelessWidget {
  final int id;
  final String name;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SpaceItem({
    required this.id,
    required this.name,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: selected ? cs.primaryContainer : null,
      child: ListTile(
        dense: true,
        leading: Icon(Icons.folder_outlined, size: 18, color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant),
        title: Text(name, style: TextStyle(fontSize: 14, color: selected ? cs.onPrimaryContainer : null)),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, size: 16, color: cs.onSurfaceVariant),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _AddSpaceButton extends StatelessWidget {
  final OfficeLogic ctl;
  final ColorScheme cs;
  final TextTheme tt;

  const _AddSpaceButton({required this.ctl, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(Icons.add, size: 18, color: cs.primary),
      title: Text(t.addSpace, style: TextStyle(fontSize: 14, color: cs.primary)),
      onTap: () {
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
    );
  }
}
