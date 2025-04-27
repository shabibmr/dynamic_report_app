import 'dart:async';

class LoaderService {
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();
  Stream<bool> get loading => _loadingController.stream;
  bool _isLoading = false;
  String? _loadingMessage;

  bool get isLoading => _isLoading;
  String? get loadingMessage => _loadingMessage;

  void show({String? message}) {
    if (!_isLoading || _loadingMessage != message) {
      _isLoading = true;
      _loadingMessage = message;
      _loadingController.add(true);
    }
  }

  void hide() {
    if (_isLoading) {
      _isLoading = false;
      _loadingMessage = null;
      _loadingController.add(false);
    }
  }

  Future<T> during<T>(Future<T> Function() task, String s, {String? message}) async {
    show(message: message);
    try {
      final result = await task();
      return result;
    } finally {
      hide();
    }
  }

  void dispose() {
    _loadingController.close();
  }

  static final LoaderService instance = LoaderService._internal();
  factory LoaderService() => instance;
  LoaderService._internal();
}
