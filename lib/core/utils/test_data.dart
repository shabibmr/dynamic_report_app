import 'package:dynamic_report_app/core/models/report_config.dart';

// import '../models/report.dart.txt';

class TestData {
  static List<ReportConfig> getSampleReports() {
    return [
      const ReportConfig(
        id: 1,
        reportName: 'Groupwise Sales Report',
        filters: {
          'filter by': [
            {'var-name': 'f1', 'var-value': 'group'},
          ],
          'dateTime': ['fromDateTime', 'toDateTime'],
        },
      ),
      // Add more sample reports here as needed
    ];
  }
}
