import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ContactPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isMobile) {
      return const _ContactMobile();
    }
    return const _ContactDesktop();
  }
}

/// Desktop: original double-column layout
class _ContactDesktop extends ConsumerWidget {
  const _ContactDesktop();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          NaviBar(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(child: HeaderBarWindows()),
                Expanded(
                  child: Row(
                    children: [
                      ContactSidebar(),
                      Expanded(child: ContentArea()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mobile: full-screen contact list (org tree + users)
class _ContactMobile extends ConsumerWidget {
  const _ContactMobile();

  Widget _buildLeftDrawer(BuildContext context, WidgetRef ref, ColorScheme cs, TextTheme tt,
      String avatarUrl, String userName) {
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
                          ref.watch(imProvider).loginUser.tenant.name,
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
              onTap: () { Navigator.of(context).pop(); context.push(AppRoute.PERSONAL); },
            ),
            ListTile(
              leading: const Icon(Icons.devices_outlined),
              title: const Text('登录设备'),
              onTap: () { Navigator.of(context).pop(); context.push(AppRoute.DEVICES); },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('设置'),
              onTap: () { Navigator.of(context).pop(); context.push(AppRoute.SETTINGS); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ctl = ref.watch(contactLogicProvider);
    final im = ref.watch(imProvider);
    final user = im.loginUser.user;
    final avatarUrl = CommonUtils.fixResourceUrl(user.avatar);
    final userName = user.name.isNotEmpty ? user.name : "?";

    final drawer = _buildLeftDrawer(context, ref, cs, tt, avatarUrl, userName);

    return Scaffold(
      drawer: drawer,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: cs.outlineVariant, width: 0.5),
                ),
              ),
              child: GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Row(
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
                    Text(t.contacts, style: tt.titleSmall),
                  ],
                ),
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                onChanged: (v) => ctl.search(v),
                decoration: InputDecoration(
                  hintText: t.search,
                  hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant, size: 18),
                  filled: true,
                  fillColor: cs.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
              ),
            ),
            // Category tabs
            Container(
              height: 36,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: cs.outlineVariant, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: _ContactCategoryTab(label: t.contacts, selected: ctl.mode == 0, onTap: () { if (ctl.mode != 0) { ctl.setMode(0); ctl.enterOrgRoot(); } })),
                  Expanded(child: _ContactCategoryTab(label: t.starContacts, selected: ctl.mode == 1, onTap: () => ctl.setMode(1))),
                  Expanded(child: _ContactCategoryTab(label: t.externalContacts, selected: ctl.mode == 2, onTap: () => ctl.setMode(2))),
                ],
              ),
            ),
            // Content
            Expanded(
              child: ListenableBuilder(
                listenable: ctl,
                builder: (ctx, _) {
                  switch (ctl.mode) {
                    case 0:
                      return OrganizationView();
                    default:
                      return _PlaceholderView();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCategoryTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ContactCategoryTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: selected ? cs.primary : Colors.transparent, width: 2),
          ),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, color: selected ? cs.primary : cs.onSurfaceVariant, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}

class ContactSidebar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ctl = ref.watch(contactLogicProvider);

    return ListenableBuilder(
      listenable: ctl,
      builder: (context, _) {
        return Container(
          width: 220,
          color: cs.surfaceVariant,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(t.contacts, style: tt.titleSmall),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  onChanged: (v) => ctl.search(v),
                  decoration: InputDecoration(
                    hintText: t.search,
                    hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    prefixIcon:
                        Icon(Icons.search, color: cs.onSurfaceVariant, size: 18),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _CategoryItem(
                icon: Icons.account_tree_outlined,
                label: t.contacts,
                selected: ctl.mode == 0,
                onTap: () {
                  if (ctl.mode != 0) {
                    ctl.setMode(0);
                    ctl.enterOrgRoot();
                  }
                },
              ),
              const Divider(height: 1),
              _CategoryItem(
                icon: Icons.star_border,
                label: t.starContacts,
                selected: ctl.mode == 1,
                onTap: () => ctl.setMode(1),
              ),
              _CategoryItem(
                icon: Icons.contacts_outlined,
                label: t.externalContacts,
                selected: ctl.mode == 2,
                onTap: () => ctl.setMode(2),
              ),
              _CategoryItem(
                icon: Icons.person_add_outlined,
                label: t.newFriendApplication,
                selected: ctl.mode == 3,
                onTap: () => ctl.setMode(3),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ContentArea extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = ref.watch(contactLogicProvider);

    return ListenableBuilder(
      listenable: ctl,
      builder: (context, _) {
        switch (ctl.mode) {
          case 0:
            return OrganizationView();
          default:
            return _PlaceholderView();
        }
      },
    );
  }
}

class OrganizationView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ctl = ref.watch(contactLogicProvider);

    return ListenableBuilder(
      listenable: ctl,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BreadcrumbBar(),
            const Divider(height: 1),
            Expanded(
              child: ctl.currentDepts.isEmpty && ctl.currentUsers.isEmpty
                  ? Center(
                      child: Text('暂无数据',
                          style: tt.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant)))
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount:
                          ctl.currentDepts.length + ctl.filteredUsers.length,
                      itemBuilder: (context, index) {
                        if (index < ctl.currentDepts.length) {
                          return _DeptItem(dept: ctl.currentDepts[index]);
                        }
                        return _UserItem(
                            user: ctl
                                .filteredUsers[index - ctl.currentDepts.length]);
                      },
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, indent: 60),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _BreadcrumbBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ctl = ref.watch(contactLogicProvider);
    final labels = ctl.breadcrumbLabels;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: cs.surface,
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Icon(Icons.chevron_right,
                size: 14, color: cs.onSurfaceVariant);
          }
          var idx = i ~/ 2;
          var isLast = idx == labels.length - 1;
          return GestureDetector(
            onTap: isLast ? null : () => ctl.goBackTo(idx),
            child: Text(
              labels[idx],
              style: (isLast ? tt.titleSmall : tt.bodySmall)?.copyWith(
                  color: isLast ? cs.onSurface : cs.onSurfaceVariant),
            ),
          );
        }),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: selected ? cs.secondaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: selected ? cs.onSecondaryContainer : cs.onSurface),
              const SizedBox(width: 12),
              Text(label,
                  style: tt.bodyMedium?.copyWith(
                      color: selected ? cs.onSecondaryContainer : null)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeptItem extends ConsumerWidget {
  final Department dept;
  const _DeptItem({required this.dept});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () =>
          ref.read(contactLogicProvider).enterDept(dept.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.folder_outlined, size: 20, color: cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(child: Text(dept.name, style: tt.bodyMedium)),
            Text('${dept.memberIds.length}人',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _UserItem extends ConsumerWidget {
  final User user;
  const _UserItem({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _showUserProfile(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _buildAvatar(cs, tt),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: tt.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    _deptName(ref),
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: user.status == 1
                    ? const Color(0xFF10CC64)
                    : cs.onSurfaceVariant.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme cs, TextTheme tt) {
    if (user.avatar.isEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: tt.bodySmall?.copyWith(color: cs.onPrimary),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image(
        width: 32,
        height: 32,
        image: CachedNetworkImageProvider(
          CommonUtils.fixResourceUrl(user.avatar),
        ),
        fit: BoxFit.cover,
      ),
    );
  }

  String _deptName(WidgetRef ref) {
    final ctl = ref.read(contactLogicProvider);
    final dept = ctl.navPath.isNotEmpty ? ctl.navPath.last.name : '';
    return dept;
  }

  void _showUserProfile(BuildContext context, WidgetRef ref) {
    final im = ref.read(imProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildAvatar(
                        Theme.of(context).colorScheme,
                        Theme.of(context).textTheme),
                    const SizedBox(height: 12),
                    Text(user.name,
                        style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
              ),
              const Divider(height: 1),
              GestureDetector(
                onTap: () async {
                  var chatId = await im.createP2PChat(user.id);
                  if (chatId != null) {
                    im.enterChat(chatId);
                  }
                  Navigator.of(ctx).pop();
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  child: Text(t.sendMessage,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.primary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Text('敬请期待',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
    );
  }
}
