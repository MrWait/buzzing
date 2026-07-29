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
  static const SETTINGS = "/settings";
  static const OFFICE = "/office";
  static const GROUP_PROFILE = "/group_profile";
  static const MEMBER_LIST = "/member_list";
  static const JOIN_REQUESTS = "/join_requests";
  static const INVITE_LINKS = "/invite_links";
  static const SEARCH = "/search";
  static const OPEN_PLATFORM = "/open-platform";
  static const PERSONAL = "/personal";
  static const DEVICES = "/devices";
  static const VC = "/vc";
  static const WEBVIEW = "/webview";
  static const CONTACT_PICKER = "/contact_picker";
}

extension RoutesExtention on String {
  String toRoute() => '/${toLowerCase()}';
}
