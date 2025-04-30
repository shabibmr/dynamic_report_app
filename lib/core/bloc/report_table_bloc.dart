import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../utils/number_formatter.dart';
import '../models/report_config.dart';
import 'package:equatable/equatable.dart';
part 'report_table_event.dart';
part 'report_table_state.dart';

class ReportTableBloc extends Bloc<ReportTableEvent, ReportTableState> {
  ReportTableBloc() : super(const ReportTableState()) {
    on<InitializeReportTable>(_onInitialize);
    on<SearchReportTable>(_onSearch);
    on<SortReportTable>(_onSort);
  }

  void _onInitialize(
    InitializeReportTable event,
    Emitter<ReportTableState> emit,
  ) {
    emit(state.copyWith(
      isLoading: true,
      error: null,
    ));
    print('Tablebloc Rows : ${event.rows.length}');
    print('Tablebloc Columns : ${event.columns.length}');
    if (event.rows.isEmpty && event.columns.isEmpty) {
      emit(state.copyWith(
        report: event.report,
        columns: [],
        rows: [],
        filteredRows: [],
        totalRows: [],
        isLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      report: event.report,
      columns: event.columns,
      rows: event.rows,
      filteredRows: event.rows,
      showTotals: event.showTotals,
      isLoading: false,
    ));
    print('initializeReportTable');
    _calculateTotals(emit);
    print('calculateTotals');
  }

  void _onSearch(
    SearchReportTable event,
    Emitter<ReportTableState> emit,
  ) {
    final query = event.query.toLowerCase();

    emit(state.copyWith(
      searchString: query,
      isLoading: true,
    ));
    final filteredRows = query.isEmpty
        ? state.rows
        : state.rows.where((row) {
            return row.cells.values.any((cell) {
              final value = cell.value?.toString().toLowerCase() ?? '';
              return value.contains(query);
            });
          }).toList();
    // print('Rows after search: ${filteredRows.length}');
    emit(state.copyWith(
      filteredRows: filteredRows,
      isLoading: false,
    ));
    _calculateTotals(emit);
  }

  void _onSort(
    SortReportTable event,
    Emitter<ReportTableState> emit,
  ) {
    final sortedRows = List<PlutoRow>.from(state.filteredRows)
      ..sort((a, b) {
        final aValue = a.cells[event.columnField]!.value;
        final bValue = b.cells[event.columnField]!.value;

        if (aValue == null || bValue == null) {
          return 0;
        }

        final comparison =
            Comparable.compare(aValue.toString(), bValue.toString());
        return event.ascending ? comparison : -comparison;
      });

    emit(state.copyWith(filteredRows: sortedRows));
    _calculateTotals(emit);
  }

  void _calculateTotals(Emitter<ReportTableState> emit) {
    if (!state.showTotals || state.report?.displayOptions == null) {
      emit(state.copyWith(totalRows: const []));
      return;
    }

    final totalsConfig = state.report!.displayOptions!['Totals'] as List?;
    if (totalsConfig == null || totalsConfig.isEmpty) {
      emit(state.copyWith(totalRows: const []));
      return;
    }

    final Map<String, num> totals = {};

    for (final row in state.filteredRows) {
      for (final column in state.columns) {
        final colIndex = state.columns.indexOf(column);
        if (totalsConfig.contains(colIndex)) {
          final value = row.cells[column.field]?.value;
          if (value != null) {
            final numValue = NumberFormatter.tryParse(value.toString());
            if (numValue != null) {
              totals[column.field] = (totals[column.field] ?? 0) + numValue;
            }
          }
        }
      }
    }

    if (totals.isNotEmpty) {
      final cells = <String, PlutoCell>{};
      for (final column in state.columns) {
        final value = totals[column.field];
        cells[column.field] = PlutoCell(
          value: value != null
              ? NumberFormatter.formatDecimal(value)
              : column.field == state.columns.first.field
                  ? 'Total'
                  : '',
        );
      }
      emit(state.copyWith(totalRows: [PlutoRow(cells: cells)]));
    } else {
      emit(state.copyWith(totalRows: const []));
    }
  }
}
