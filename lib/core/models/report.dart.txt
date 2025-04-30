import 'dart:convert';

class Report {
  final int id;
  final String reportName;
  final Map<String, dynamic>? filters;

  Report({required this.id, required this.reportName, this.filters});

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      reportName: json['report_name'],
      filters:
          json['filters'] != null
              ? Map<String, dynamic>.from(
                json['filters'] is String
                    ? jsonDecode(json['filters'])
                    : json['filters'],
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'report_name': reportName, 'filters': filters,};
  }
}
