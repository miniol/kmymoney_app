import 'dart:async';

// Emit when DB changes
// (sqflite is NOT reactive. It does not emit table change events, so we need to manually emit them.)
class DbChangeNotifier {
  static final DbChangeNotifier instance = DbChangeNotifier._internal();

  final _controller = StreamController<void>.broadcast();

  DbChangeNotifier._internal();

  Stream<void> get stream => _controller.stream;

  void notify() {
    _controller.add(null);
  }
}
