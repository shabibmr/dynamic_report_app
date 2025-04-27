import 'dart:convert';
import 'package:equatable/equatable.dart';

class ReportConfig extends Equatable {
  final int id;
  final String reportName;
  final String? module;
  final String? uiType;
  final String? subType;
  final String? query;
  final Map<String, dynamic>? filters;
  final Map<String, dynamic>? displayOptions;
  final Map<String, dynamic>? redirectTo;
  final String? extras;

  const ReportConfig({
    required this.id,
    required this.reportName,
    this.module,
    this.uiType,
    this.subType,
    this.query,
    this.filters,
    this.displayOptions,
    this.redirectTo,
    this.extras,
  });

  factory ReportConfig.fromJson(Map<String, dynamic> json) {
    return ReportConfig(
      id: json['_id'],
      reportName: json['report_name'],
      module: json['Module'],
      uiType: json['ui_type'],
      subType: json['sub_type'],
      query: json['query'],
      filters: json['filters'] != null ? jsonDecode(json['filters']) : null,
      displayOptions:
          json['display_options'] != null
              ? jsonDecode(json['display_options'])
              : null,
      redirectTo:
          json['redirect_to'] != null ? jsonDecode(json['redirect_to']) : null,
      extras: json['Extras'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'report_name': reportName,
      'Module': module,
      'ui_type': uiType,
      'sub_type': subType,
      'query': query,
      'filters': filters != null ? jsonEncode(filters) : null,
      'display_options':
          displayOptions != null ? jsonEncode(displayOptions) : null,
      'redirect_to': redirectTo != null ? jsonEncode(redirectTo) : null,
      'Extras': extras,
    };
  }

  @override
  List<Object?> get props => [
    id,
    reportName,
    module,
    uiType,
    subType,
    query,
    filters,
    displayOptions,
    redirectTo,
    extras,
  ];
}
