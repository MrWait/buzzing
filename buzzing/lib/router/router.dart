import 'package:buzzing/page/calendar/calendar_view.dart';
import 'package:buzzing/page/chat/chat_view.dart';
import 'package:buzzing/page/chat/group_edit_page.dart';
import 'package:buzzing/page/chat/group_manage_page.dart';
import 'package:buzzing/page/chat/group_profile_page.dart';
import 'package:buzzing/page/chat/group_share.dart';
import 'package:buzzing/page/chat/join_requests_page.dart';
import 'package:buzzing/page/chat/member_list_page.dart';
import 'package:buzzing/page/contact/contact_view.dart';
import 'package:buzzing/page/im/contact_picker_page.dart';
import 'package:buzzing/page/devices/devices_page.dart';
import 'package:buzzing/page/im/im_view.dart';
import 'package:buzzing/page/login/login_view.dart';
import 'package:buzzing/page/meeting/meeting_view.dart';
import 'package:buzzing/page/office/office_view.dart';
import 'package:buzzing/page/personal/personal_page.dart';
import 'package:buzzing/page/vc/vc_view.dart';
import 'package:buzzing/webview.dart';
import 'package:buzzing/page/openapp/openapp_list_page.dart';
import 'package:buzzing/page/search/search_view.dart';
import 'package:buzzing/page/setting/settings_page.dart';
import 'package:buzzing/page/splash/splash_view.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:buzzing/widget/mobile_shell.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final tabRoutes = <GoRoute>[
    GoRoute(
      path: AppRoute.IM,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, const ImPage()),
      routes: isMobile
          ? [
              GoRoute(
                path: 'chat/:chatId',
                pageBuilder: (ctx, state) => _pageBuilder(
                  ctx,
                  state,
                  ChatPage(routeChatId: state.pathParameters['chatId']!),
                ),
              ),
            ]
          : [],
    ),
    GoRoute(
      path: AppRoute.CONTACT,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, ContactPage()),
    ),
    GoRoute(
      path: AppRoute.CALENDAR,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, CalendarPage()),
    ),
    GoRoute(
      path: AppRoute.MEETING,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, MeetingPage()),
    ),
    GoRoute(
      path: AppRoute.OFFICE,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, const OfficePage()),
    ),
  ];

  final fullRoutes = <GoRoute>[
    GoRoute(
      path: AppRoute.SPLASH,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, SplashPage()),
    ),
    GoRoute(
      path: AppRoute.LOGIN,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, LoginPage()),
    ),
    GoRoute(
      path: AppRoute.PERSONAL,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, const PersonalPage()),
    ),
    GoRoute(
      path: AppRoute.DEVICES,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, const DevicesPage()),
    ),
    GoRoute(
      path: AppRoute.SETTINGS,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, SettingsPage()),
    ),
    GoRoute(
      path: AppRoute.SEARCH,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, SearchPage()),
    ),
    GoRoute(
      path: AppRoute.CONTACT_PICKER,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, const ContactPickerPage()),
    ),
    GoRoute(
      path: AppRoute.OPEN_PLATFORM,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, OpenAppListPage()),
    ),
    GoRoute(
      path: '${AppRoute.GROUP_PROFILE}/:chatId',
      pageBuilder: (ctx, state) => _pageBuilder(
        ctx,
        state,
        GroupProfilePage(chatId: Int64(int.parse(state.pathParameters['chatId']!))),
      ),
    ),
    GoRoute(
      path: '${AppRoute.MEMBER_LIST}/:chatId',
      pageBuilder: (ctx, state) => _pageBuilder(
        ctx,
        state,
        MemberListPage(chatId: Int64(int.parse(state.pathParameters['chatId']!))),
      ),
    ),
    GoRoute(
      path: '${AppRoute.GROUP_EDIT}/:chatId',
      pageBuilder: (ctx, state) => _pageBuilder(
        ctx,
        state,
        GroupEditPage(chatId: Int64(int.parse(state.pathParameters['chatId']!))),
      ),
    ),
    GoRoute(
      path: '${AppRoute.GROUP_SHARE}/:chatId',
      pageBuilder: (ctx, state) => _pageBuilder(
        ctx,
        state,
        GroupSharePage(chatId: Int64(int.parse(state.pathParameters['chatId']!))),
      ),
    ),
    GoRoute(
      path: '${AppRoute.JOIN_REQUESTS}/:chatId',
      pageBuilder: (ctx, state) => _pageBuilder(
        ctx,
        state,
        JoinRequestsPage(chatId: Int64(int.parse(state.pathParameters['chatId']!))),
      ),
    ),
    GoRoute(
      path: '${AppRoute.GROUP_MANAGE}/:chatId',
      pageBuilder: (ctx, state) => _pageBuilder(
        ctx,
        state,
        GroupManagePage(chatId: Int64(int.parse(state.pathParameters['chatId']!))),
      ),
    ),
    GoRoute(
      path: AppRoute.VC,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, const VcPage()),
    ),
    GoRoute(
      path: AppRoute.WEBVIEW,
      pageBuilder: (ctx, state) => _pageBuilder(ctx, state, const WebviewPage()),
    ),
  ];

  if (isDesktop) {
    return GoRouter(
      initialLocation: AppRoute.SPLASH,
      routes: [...tabRoutes, ...fullRoutes],
    );
  }

  return GoRouter(
    initialLocation: AppRoute.SPLASH,
    routes: [
      ShellRoute(
        builder: (ctx, state, child) => MobileShell(child: child),
        routes: tabRoutes,
      ),
      ...fullRoutes,
    ],
  );
});

Page<Object> _pageBuilder(BuildContext ctx, GoRouterState state, Widget child) {
  if (isDesktop) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (ctx, anim, secAnim, child) => child,
    );
  }
  return MaterialPage(child: child, key: state.pageKey);
}
