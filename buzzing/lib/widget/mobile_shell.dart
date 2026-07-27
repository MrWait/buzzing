import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MobileShell extends ConsumerWidget {
  final Widget child;

  const MobileShell({super.key, required this.child});

  int _tabIndex(String location) {
    if (location.startsWith(AppRoute.IM)) return 0;
    if (location.startsWith(AppRoute.CALENDAR)) return 1;
    if (location.startsWith(AppRoute.MEETING)) return 2;
    if (location.startsWith(AppRoute.CONTACT)) return 3;
    if (location.startsWith(AppRoute.OFFICE)) return 4;
    return 0;
  }

  bool _showBottomNav(String location) {
    // Hide bottom nav on chat sub-route (full-screen chat on mobile)
    if (location.startsWith('${AppRoute.IM}/chat/')) return false;
    return true;
  }

  void _goToTab(BuildContext context, int index) {
    final router = GoRouter.of(context);
    switch (index) {
      case 0:
        router.go(AppRoute.IM);
        break;
      case 1:
        router.go(AppRoute.CALENDAR);
        break;
      case 2:
        router.go(AppRoute.MEETING);
        break;
      case 3:
        router.go(AppRoute.CONTACT);
        break;
      case 4:
        router.go(AppRoute.OFFICE);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isDesktop) return child;

    final router = GoRouter.of(context);
    final location = router.state.uri.toString();
    final index = _tabIndex(location);
    final showNav = _showBottomNav(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: showNav
          ? NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => _goToTab(context, i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.message), label: '消息'),
                NavigationDestination(icon: Icon(Icons.calendar_month), label: '日历'),
                NavigationDestination(icon: Icon(Icons.video_call), label: '会议'),
                NavigationDestination(icon: Icon(Icons.contact_page), label: '联系人'),
                NavigationDestination(icon: Icon(Icons.description), label: '办公'),
              ],
            )
          : null,
    );
  }
}
