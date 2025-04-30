part of 'report_list_bloc.dart';

enum ReportListStatus { initial, loading, success, failure }

class ReportListState extends Equatable {
  final ReportListStatus status;
  final List<ReportConfig> reports;
  final ReportConfig? selectedReport;
  final String? error;

  const ReportListState({
    this.status = ReportListStatus.initial,
    this.reports = const [],
    // List<ReportConfig>? filteredReports,
    this.selectedReport,
    this.error,
  });
  //: filteredReports = filteredReports ?? reports;

  ReportListState copyWith({
    ReportListStatus? status,
    List<ReportConfig>? reports,
    // List<ReportConfig>? filteredReports,
    ReportConfig? selectedReport,
    String? error,
  }) {
    return ReportListState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      selectedReport: selectedReport ?? this.selectedReport,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reports,
        selectedReport,
        error,
      ];
}
