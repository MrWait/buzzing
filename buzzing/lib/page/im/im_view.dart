import 'package:buzzing/page/chat/chat_view.dart';
import 'package:buzzing/page/feed/feed_view.dart';
import 'package:buzzing/provider/im_provider.dart';
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

class ImPage extends ConsumerWidget {
  const ImPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isMobile) {
      return const _ImMobile();
    }
    return const _ImDesktop();
  }
}

/// Mobile: full-screen FeedPage (ChatPage is pushed as separate route)
class _ImMobile extends ConsumerWidget {
  const _ImMobile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final im = ref.watch(imProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final user = im.loginUser.user;
    final userName = user.name.isNotEmpty ? user.name : "?";
    final avatarUrl = CommonUtils.fixResourceUrl(user.avatar);

    return Scaffold(
      drawer: buildMobileDrawer(context, ref),
      body: Builder(
        builder: (ctx) => SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: cs.outlineVariant, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                        Text(userName, style: tt.titleSmall),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, size: 20),
                    onPressed: () => context.push(AppRoute.SEARCH),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    offset: const Offset(0, 40),
                    icon: const Icon(Icons.add, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(36, 36),
                    ),
                    onSelected: (value) {
                      if (value == 'create_group') {
                        context.push(AppRoute.CONTACT_PICKER);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'create_group',
                        child: const Text('创建群聊'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Expanded(child: FeedPage()),
          ],
        ),
      ),
    ),
    );
  }
}

/// Desktop: 3-column layout
class _ImDesktop extends StatelessWidget {
  const _ImDesktop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        NaviBar(),
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(child: HeaderBarWindows()),
            Expanded(
              child: Row(
                children: [
                  const FeedPage(),
                  const Expanded(
                    child: ChatPage(),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
