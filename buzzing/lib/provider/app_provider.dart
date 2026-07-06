import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../event/event_bus.dart';

final eventBusProvider = Provider<EventBus>((ref) {
  final bus = EventBus();
  ref.onDispose(() => bus.dispose());
  return bus;
});
