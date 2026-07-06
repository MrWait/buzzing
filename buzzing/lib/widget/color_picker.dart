import 'package:buzzing/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class ColorPickerDialog extends StatelessWidget {
  final int currentColor;
  final Function(int) onSelected;

  const ColorPickerDialog({
    required this.currentColor,
    required this.onSelected,
  });

  static const _colors = [
    0xFF3370FF,
    0xFF10CC64,
    0xFFFFC563,
    0xFFFF6B6B,
    0xFF9B59B6,
    0xFF1ABC9C,
    0xFFE74C3C,
    0xFF3498DB,
    0xFFF39C12,
    0xFF2ECC71,
    0xFFE91E63,
    0xFF607D8B,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.chooseColor),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _colors.map((c) {
          var selected = c == currentColor;
          return GestureDetector(
            onTap: () {
              onSelected(c);
              Navigator.of(context).pop();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color(c),
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: selected
                    ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                    : null,
              ),
              child: selected
                  ? Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
