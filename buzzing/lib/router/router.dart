import 'dart:io';

import 'package:buzzing/page/calendar/calendar_view.dart';
import 'package:buzzing/page/contact/contact_view.dart';
import 'package:buzzing/page/im/im_view.dart';
import 'package:buzzing/page/login/login_view.dart';
import 'package:buzzing/page/meeting/meeting_view.dart';
import 'package:buzzing/page/chat/group_profile_page.dart';
import 'package:buzzing/page/chat/member_list_page.dart';
import 'package:buzzing/page/chat/join_requests_page.dart';
import 'package:buzzing/page/chat/invite_links_page.dart';
import 'package:buzzing/page/office/office_view.dart';
import 'package:buzzing/page/setting/settings_page.dart';
import 'package:buzzing/page/splash/splash_view.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.SPLASH,
    routes: [
      GoRoute(
        path: AppRoute.SPLASH,
        pageBuilder: (ctx, state) => _noTransitionPage(
          ctx,
          state,
          SplashPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.LOGIN,
        pageBuilder: (ctx, state) => _noTransitionPage(
          ctx,
          state,
          LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.IM,
        pageBuilder: (ctx, state) => _noTransitionPage(
          ctx,
          state,
          ImPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.CONTACT,
        pageBuilder: (ctx, state) => _noTransitionPage(
          ctx,
          state,
          ContactPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.CALENDAR,
        pageBuilder: (ctx, state) => _noTransitionPage(
          ctx,
          state,
          CalendarPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.MEETING,
        pageBuilder: (ctx, state) => _noTransitionPage(
          ctx,
          state,
          MeetingPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.SETTINGS,
        pageBuilder: (ctx, state) => _noTransitionPage(
          ctx,
          state,
          SettingsPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.OFFICE,
        pageBuilder: (ctx, state) => _noTransitionPage(
          ctx,
          state,
          const OfficePage(),
        ),
      ),
      GoRoute(
        path: '${AppRoute.GROUP_PROFILE}/:chatId',
        pageBuilder: (ctx, state) => _noTransitionPage(
          ctx,
          state,
          GroupProfilePage(chatId: Int64(int.parse(state.pathParameters['chatId']!))),
        ),
      ),
      GoRoute(
        path: '${AppRoute.MEMBER_LIST}/:chatId',
        pageBuilder: (ctx, state) => _noTransitionPage(
          ctx,
          state,
          MemberListPage(chatId: Int64(int.parse(state.pathParameters['chatId']!))),
        ),
      ),
      GoRoute(
        path: '${AppRoute.JOIN_REQUESTS}/:chatId',
        pageBuilder: (ctx, state) => _noTransitionPage(
          ctx,
          state,
          JoinRequestsPage(chatId: Int64(int.parse(state.pathParameters['chatId']!))),
        ),
      ),
      GoRoute(
        path: '${AppRoute.INVITE_LINKS}/:chatId',
        pageBuilder: (ctx, state) => _noTransitionPage(
          ctx,
          state,
          InviteLinksPage(chatId: Int64(int.parse(state.pathParameters['chatId']!))),
        ),
      ),
    ],
  );
});

Page<Object> _noTransitionPage(BuildContext ctx, GoRouterState state, Widget child) {
  if (_isDesktop) {
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

