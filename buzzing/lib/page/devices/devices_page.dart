import 'package:flutter/material.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('登录设备')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.devices, size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('暂无其他登录设备', style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
