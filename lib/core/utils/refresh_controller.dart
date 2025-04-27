import 'dart:async';

class RefreshController {
  final StreamController<void> _refreshController =
      StreamController<void>.broadcast();
  Stream<void> get onRefresh => _refreshController.stream;

  void refresh() {
    _refreshController.add(null);
  }

  void dispose() {
    _refreshController.close();
  }

  static final RefreshController _instance = RefreshController._internal();
  factory RefreshController() => _instance;
  RefreshController._internal();
}
