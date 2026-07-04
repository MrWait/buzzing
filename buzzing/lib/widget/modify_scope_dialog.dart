import 'package:flutter/material.dart';

class ModifyScopeDialog extends StatelessWidget {
  final bool isDelete;

  const ModifyScopeDialog({this.isDelete = false});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isDelete ? "Delete repeating schedule" : "Edit repeating schedule"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("How would you like to apply changes?"),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.event),
          title: const Text("This event"),
          subtitle: const Text("Change only this occurrence"),
          onTap: () => Navigator.of(context).pop(0),
        ),
        ListTile(
          leading: const Icon(Icons.event_repeat),
          title: const Text("All events"),
          subtitle: const Text("Change all occurrences in the series"),
          onTap: () => Navigator.of(context).pop(1),
        ),
        ListTile(
          leading: const Icon(Icons.forward),
          title: const Text("This and future events"),
          subtitle: const Text("Change this and all future occurrences"),
          onTap: () => Navigator.of(context).pop(2),
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
