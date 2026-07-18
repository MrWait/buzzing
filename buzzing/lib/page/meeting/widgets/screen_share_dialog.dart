import 'package:buzzing/i18n/strings.g.dart';
import 'package:flutter/material.dart';

void showScreenShareDialog(BuildContext context, VoidCallback onStart) {
  final t = Translations.of(context);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t.shareScreen),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.desktop_windows, size: 28),
            title: Text(t.shareEntireScreen),
            subtitle: Text(t.shareEntireScreenDesc),
            onTap: () {
              Navigator.of(ctx).pop();
              onStart();
            },
          ),
          ListTile(
            leading: const Icon(Icons.window, size: 28),
            title: Text(t.shareWindow),
            subtitle: Text(t.shareWindowDesc),
            onTap: () {
              Navigator.of(ctx).pop();
              onStart();
            },
          ),
        ],
      ),
    ),
  );
}
