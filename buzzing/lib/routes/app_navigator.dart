import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/utils/data_persistence.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

class AppNavigator {
  static void backLogin(GoRouter router) {
    router.go(AppRoute.LOGIN);
  }

  static void startLogin(GoRouter router) {
    router.go(AppRoute.LOGIN);
  }

  static void startRegister(GoRouter router, String way) {
    router.push(AppRoute.REGISTER, extra: {'registerWay': way});
  }

  static void startIm(GoRouter router, LoginUser? user) {
    router.go(AppRoute.IM);
  }

  static void startContact(GoRouter router) {
    router.go(AppRoute.CONTACT);
  }

  static void startCalendar(GoRouter router) {
    router.go(AppRoute.CALENDAR);
  }

  static void startMeeting(GoRouter router) {
    router.go(AppRoute.MEETING);
  }

  static void startRegisterVerifyPhoneOrEmail({
    required GoRouter router,
    String? email,
    String? phoneNumber,
    String? areaCode,
    required int usedFor,
    String? invitationCode,
  }) {
    router.push(AppRoute.REGISTER_VERIFY_PHONE, extra: {
      'phoneNumber': phoneNumber,
      'areaCode': areaCode,
      'email': email,
      'usedFor': usedFor,
      'invitationCode': invitationCode,
    });
  }
}
