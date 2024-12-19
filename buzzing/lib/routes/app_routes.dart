part of 'app_pages.dart';

abstract class AppRoute {
  static const NOT_FOUND = '/not-found';
  static const LOGIN = '/login';
  static const SPLASH = '/splash';
  static const REGISTER = '/register';
  static const REGISTER_VERIFY_PHONE = '/register_verify_phone';
  static const REGISTER_SETUP_PWD = '/register_setup_pwd';
  static const REGISTER_SETUP_SELF_INFO = '/register_setup_selfinfo';
  static const HOME = '/home';
  static const CHAT = '/chat';
  static const CHAT_SETUP = '/chat_setup';
  static const IM = "/im";
  static const CONTACT = "/contact";
  static const CALENDAR = "/calendar";
  static const MEETING = "/meeting";
}

extension RoutesExtention on String {
  String toRoute() => '/${toLowerCase()}';
}
