import 'package:buzzing/page/calendar/calendar_binding.dart';
import 'package:buzzing/page/calendar/calendar_view.dart';
import 'package:buzzing/page/im/im_binding.dart';
import 'package:buzzing/page/im/im_view.dart';
import 'package:buzzing/page/login/login_binding.dart';
import 'package:buzzing/page/login/login_view.dart';
import 'package:buzzing/page/meeting/meeting_binding.dart';
import 'package:buzzing/page/meeting/meeting_view.dart';
import 'package:buzzing/page/splash/splash_binding.dart';
import 'package:buzzing/page/splash/splash_logic.dart';
import 'package:buzzing/page/splash/splash_view.dart';
import 'package:buzzing/page/contact/contact_binding.dart';
import 'package:buzzing/page/contact/contact_logic.dart';
import 'package:buzzing/page/contact/contact_view.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: AppRoute.SPLASH,
      page: () => SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoute.LOGIN,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoute.IM,
      page: () => ImPage(),
      binding: ImBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoute.CONTACT,
      page: () => ContactPage(),
      binding: ContactBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoute.CALENDAR,
      page: () => CalendarPage(),
      binding: CalendarBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoute.MEETING,
      page: () => MeetingPage(),
      binding: MeetingBinding(),
      transition: Transition.noTransition,
    ),
  ];
}
