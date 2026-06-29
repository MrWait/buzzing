import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/sdk_controller.dart';
import 'app_provider.dart';

final sdkProvider = Provider<SdkController>((ref) {
  final bus = ref.watch(eventBusProvider);
  return SdkController(eventBus: bus);
});
