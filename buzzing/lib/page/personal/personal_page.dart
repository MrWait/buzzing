import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalPage extends ConsumerWidget {
  const PersonalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final im = ref.watch(imProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final user = im.loginUser.user;
    final tenant = im.loginUser.tenant;
    final userName = user.name.isNotEmpty ? user.name : "?";
    final avatarUrl = CommonUtils.fixResourceUrl(user.avatar);

    return Scaffold(
      appBar: AppBar(title: const Text('个人名片')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: avatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(avatarUrl)
                      : null,
                  child: avatarUrl.isEmpty
                      ? Text(userName[0], style: tt.headlineMedium)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(userName, style: tt.titleLarge),
                const SizedBox(height: 4),
                Text(tenant.name, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
