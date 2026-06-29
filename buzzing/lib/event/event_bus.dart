import 'dart:async';

enum GlobalEvent {
  logined(1),
  messageUpdate(2),
  feedlistUpdate(3);

  final int num;
  const GlobalEvent(this.num);
}

class EventBus {
  final _controller = StreamController<GlobalEvent>.broadcast();
  Stream<GlobalEvent> get stream => _controller.stream;

  void emit(GlobalEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}
