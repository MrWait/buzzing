import 'package:flutter/material.dart';

class StickerWidget extends StatelessWidget {
  late IconData icon;
  late String name = "Name";
  StickerWidget({required icon, required name})
      : icon = icon,
        name = name;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
        height: 60,
        width: 40,
        child: Column(
          children: [
            Icon(icon, color: cs.primary),
            Text("Name", textAlign: TextAlign.center),
          ],
        ));
  }
}

List<Widget> genSticker() {
  return <Widget>[
    StickerWidget(icon: Icons.group, name: "N1"),
    StickerWidget(icon: Icons.group, name: "N1"),
    StickerWidget(icon: Icons.group, name: "N1"),
    StickerWidget(icon: Icons.group, name: "N1"),
    StickerWidget(icon: Icons.group, name: "N1"),
    StickerWidget(icon: Icons.group, name: "N1"),
    StickerWidget(icon: Icons.group, name: "N1"),
    StickerWidget(icon: Icons.group, name: "N1"),
    StickerWidget(icon: Icons.group, name: "N1"),
    StickerWidget(icon: Icons.group, name: "N1"),
    StickerWidget(icon: Icons.group, name: "N1"),
    StickerWidget(icon: Icons.group, name: "N1"),
    StickerWidget(icon: Icons.group, name: "N1"),
  ];
}
