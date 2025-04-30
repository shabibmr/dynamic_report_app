part of 'report_detail_bloc.dart';

abstract class ReportDetailEvent extends Equatable {
  const ReportDetailEvent();

  @override
  List<Object?> get props => [];
}

class ExecuteReport extends ReportDetailEvent {
  final ReportConfig report;
  // final Map<String, dynamic> filters;

  const ExecuteReport({required this.report});

  @override
  List<Object?> get props => [report];
}

class SetSelectedReport extends ReportDetailEvent {
  final ReportConfig report;

  const SetSelectedReport({required this.report});

  @override
  List<Object?> get props => [report];
}
