import 'package:buzzing/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class ModifyScopeDialog extends StatelessWidget {
  final bool isDelete;

  const ModifyScopeDialog({this.isDelete = false});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isDelete ? t.deleteRepeatingSchedule : t.editRepeatingSchedule),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(t.howToApply),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(t.thisEvent),
          subtitle: Text(t.changeOnlyThis),
          onTap: () => Navigator.of(context).pop(0),
        ),
        ListTile(
          leading: const Icon(Icons.event_repeat),
          title: Text(t.allEvents),
          subtitle: Text(t.changeAll),
          onTap: () => Navigator.of(context).pop(1),
        ),
        ListTile(
          leading: const Icon(Icons.forward),
          title: Text(t.futureEvents),
          subtitle: Text(t.changeFuture),
          onTap: () => Navigator.of(context).pop(2),
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(t.cancel),
        ),
      ],
    );
  }
}
