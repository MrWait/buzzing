import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/im.dart';
import 'app_provider.dart';
import 'sdk_provider.dart';

final imProvider = Provider<ImController>((ref) {
  final sdk = ref.watch(sdkProvider);
  final bus = ref.watch(eventBusProvider);
  return ImController(sdk: sdk, ev: bus);
});
