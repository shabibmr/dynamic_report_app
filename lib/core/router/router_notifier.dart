import 'package:flutter/material.dart';
import '../repositories/report_repository.dart';
import '../models/report_config.dart';

class RouterNotifier extends ChangeNotifier {
  final ReportRepository _reportRepository;
  List<ReportConfig> _reports = [];

  RouterNotifier(this._reportRepository) {
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      _reports = await _reportRepository.getReportsList();
      notifyListeners();
    } catch (e) {
      // Handle error silently, reports will be empty
      _reports = [];
      notifyListeners();
    }
  }

  ReportConfig? getReportById(int id) {
    try {
      return _reports.firstWhere((report) => report.id == id);
    } catch (_) {
      return null;
    }
  }

  void refresh() => _loadReports();
}
