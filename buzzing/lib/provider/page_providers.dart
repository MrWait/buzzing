import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../page/login/login_logic.dart';
import '../page/splash/splash_logic.dart';
import '../page/calendar/calendar_logic.dart';
import '../page/meeting/meeting_home_logic.dart';
import '../page/meeting/meeting_logic.dart';
import '../page/contact/contact_logic.dart';
import '../page/chat/chat_logic.dart';
import '../page/feed/feed_logic.dart';
import '../utils/data_persistence.dart';
import 'sdk_provider.dart';
import 'im_provider.dart';
import 'app_state_provider.dart';

final loginLogicProvider = Provider.autoDispose<LoginLogic>((ref) {
  final sdk = ref.watch(sdkProvider);
  final logic = LoginLogic(sdk: sdk);
  logic.init();
  ref.onDispose(() => logic.dispose());
  return logic;
});

final splashLogicProvider = Provider.autoDispose<SplashLogic>((ref) {
  final sdk = ref.watch(sdkProvider);
  final logic = SplashLogic(sdk: sdk);
  ref.onDispose(() => logic.dispose());
  return logic;
});

final calendarLogicProvider = Provider.autoDispose<CalendarLogic>((ref) {
  final sdk = ref.watch(sdkProvider);
  final logic = CalendarLogic(sdk: sdk);
  logic.init();
  return logic;
});

final meetingHomeLogicProvider = Provider.autoDispose<MeetingHomeLogic>((ref) {
  final sdk = ref.watch(sdkProvider);
  final logic = MeetingHomeLogic(sdk: sdk);
  logic.init();
  return logic;
});

final meetingLogicProvider = Provider.autoDispose<MeetingLogic>((ref) {
  final app = ref.watch(appControllerProvider);
  final account = DataPersistence.getAccount();
  var accountLoginUser = account?.loginUser;
  final token = accountLoginUser?.token ?? '';
  final userName = accountLoginUser?.user.name ?? '';
  final logic = MeetingLogic(app: app, token: token, userName: userName);
  logic.init();
  return logic;
});

final contactLogicProvider = Provider.autoDispose<ContactController>((ref) {
  final im = ref.watch(imProvider);
  final logic = ContactController(im: im);
  Future.microtask(() => logic.enterOrgRoot());
  return logic;
});

final chatLogicProvider = Provider<ChatLogic>((ref) => ChatLogic());
final feedLogicProvider = Provider<FeedLogic>((ref) => FeedLogic());
