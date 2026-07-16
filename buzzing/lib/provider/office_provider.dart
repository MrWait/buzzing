import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../page/office/office_logic.dart';
import 'sdk_provider.dart';

final officeLogicProvider = Provider.autoDispose<OfficeLogic>((ref) {
  final sdk = ref.watch(sdkProvider);
  final logic = OfficeLogic();
  final token = sdk.token;
  if (token != null && token.isNotEmpty) {
    logic.init(token);
  }
  ref.onDispose(() {});
  return logic;
});
