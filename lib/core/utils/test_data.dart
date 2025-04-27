import '../models/report.dart';

class TestData {
  static List<Report> getSampleReports() {
    return [
      Report(
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
