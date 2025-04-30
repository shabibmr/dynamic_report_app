part of 'report_table_bloc.dart';

class ReportTableState extends Equatable {
  final ReportConfig? report;
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final List<PlutoRow> filteredRows;
  final List<PlutoRow> totalRows;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  final bool showTotals;
  final String? searchString;

  const ReportTableState({
    this.report,
    this.columns = const [],
    this.rows = const [],
    this.filteredRows = const [],
    this.totalRows = const [],
    this.searchQuery = '',
    this.isLoading = true,
    this.error,
    this.showTotals = true,
    this.searchString,
  });

  ReportTableState copyWith({
    ReportConfig? report,
    List<PlutoColumn>? columns,
    List<PlutoRow>? rows,
    List<PlutoRow>? filteredRows,
    List<PlutoRow>? totalRows,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool? showTotals,
    String? searchString,
  }) {
    return ReportTableState(
      report: report ?? this.report,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      filteredRows: filteredRows ?? this.filteredRows,
      totalRows: totalRows ?? this.totalRows,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      showTotals: showTotals ?? this.showTotals,
      searchString: searchString ?? this.searchString,
    );
  }

  @override
  List<Object?> get props => [
        report,
        columns,
        rows,
        filteredRows,
        totalRows,
        searchQuery,
        isLoading,
        error,
        showTotals,
        searchString,
      ];
}
