import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Widget buildMobileDrawer(BuildContext context, WidgetRef ref) {
  final im = ref.watch(imProvider);
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;
  final user = im.loginUser.user;
  final userName = user.name.isNotEmpty ? user.name : "?";
  final avatarUrl = CommonUtils.fixResourceUrl(user.avatar);

  return Drawer(
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push(AppRoute.PERSONAL),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? CachedNetworkImageProvider(avatarUrl)
                        : null,
                    child: avatarUrl.isEmpty
                        ? Text(userName[0], style: tt.titleMedium)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: tt.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        im.loginUser.tenant.name,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('个人名片'),
            onTap: () {
              Navigator.of(context).pop();
              context.push(AppRoute.PERSONAL);
            },
          ),
          ListTile(
            leading: const Icon(Icons.devices_outlined),
            title: const Text('登录设备'),
            onTap: () {
              Navigator.of(context).pop();
              context.push(AppRoute.DEVICES);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('设置'),
            onTap: () {
              Navigator.of(context).pop();
              context.push(AppRoute.SETTINGS);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: cs.error),
            title: Text(t.logout, style: TextStyle(color: cs.error)),
            onTap: () {
              Navigator.of(context).pop();
              // onReset 兜底：销毁 im/sdk 单例，确保下一个用户从干净状态重建
              im.logout(
                GoRouter.of(context),
                onReset: () => ref.invalidate(imProvider),
              );
            },
          ),
        ],
      ),
    ),
  );
}
