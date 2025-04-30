// import '../models/report.dart.txt';
import '../models/report_config.dart';
import '../utils/test_data.dart';
import 'report_repository.dart';

class MockReportRepository implements ReportRepository {
  @override
  Future<List<ReportConfig>> getReports() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return TestData.getSampleReports();
  }

  @override
  Future<Map<String, dynamic>> executeReport(
    ReportConfig report,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock data based on the report type
    if (report.reportName.contains('Sales')) {
      return {
        'data': [
          {'Name': 'Electronics', 'Quantity': 150, 'Value': 75000.00},
          {'Name': 'Furniture', 'Quantity': 45, 'Value': 125000.00},
          {'Name': 'Accessories', 'Quantity': 300, 'Value': 15000.00},
        ],
      };
    }

    return {'data': []};
  }

  @override
  String get baseUrl => throw UnimplementedError();
}
