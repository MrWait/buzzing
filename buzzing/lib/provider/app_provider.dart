import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../event/event_bus.dart';

final eventBusProvider = Provider<EventBus>((ref) {
  final bus = EventBus();
  ref.onDispose(() => bus.dispose());
  return bus;
});

final localeProvider = StateProvider<Locale?>((ref) => null);
