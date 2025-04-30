part of 'report_detail_bloc.dart';

enum ReportDetailStatus { initial, loading, success, failure }

class ReportDetailState extends Equatable {
  final ReportDetailStatus status;
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final String? error;
  final ReportConfig? report;

  const ReportDetailState({
    this.status = ReportDetailStatus.initial,
    this.columns = const [],
    this.rows = const [],
    this.error,
    this.report,
  });

  ReportDetailState copyWith({
    ReportDetailStatus? status,
    List<PlutoColumn>? columns,
    List<PlutoRow>? rows,
    String? error,
    ReportConfig? report,
  }) {
    return ReportDetailState(
      status: status ?? this.status,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      error: error ?? this.error,
      report: report ?? this.report,
    );
  }

  @override
  List<Object?> get props => [
        status,
        columns,
        rows,
        error,
        report,
      ];
}
