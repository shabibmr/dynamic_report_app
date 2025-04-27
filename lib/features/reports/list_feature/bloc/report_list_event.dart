part of 'report_list_bloc.dart';

abstract class ReportListEvent extends Equatable {
  const ReportListEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportList extends ReportListEvent {
  const LoadReportList();
}

class SelectReport extends ReportListEvent {
  final int reportId;

  const SelectReport(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

class SearchReports extends ReportListEvent {
  final String query;

  const SearchReports(this.query);

  @override
  List<Object?> get props => [query];
}
