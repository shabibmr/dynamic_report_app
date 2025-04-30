part of 'report_table_bloc.dart';

abstract class ReportTableEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializeReportTable extends ReportTableEvent {
  final ReportConfig report;
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final bool showTotals;

  InitializeReportTable({
    required this.report,
    required this.columns,
    required this.rows,
    this.showTotals = true,
  });

  @override
  List<Object?> get props => [report, columns, rows, showTotals];
}

class SearchReportTable extends ReportTableEvent {
  final String query;

  SearchReportTable(this.query);

  @override
  List<Object?> get props => [query];
}

class SortReportTable extends ReportTableEvent {
  final String columnField;
  final bool ascending;

  SortReportTable({
    required this.columnField,
    required this.ascending,
  });

  @override
  List<Object?> get props => [columnField, ascending];
}
