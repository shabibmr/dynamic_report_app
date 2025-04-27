import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../../../../core/repositories/report_repository.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/number_formatter.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/report_config.dart';

part 'report_detail_event.dart';
part 'report_detail_state.dart';

class ReportDetailBloc extends Bloc<ReportDetailEvent, ReportDetailState> {
  final ReportRepository _reportRepository;

  ReportDetailBloc({required ReportRepository reportRepository})
    : _reportRepository = reportRepository,
      super(const ReportDetailState()) {
    on<ExecuteReport>(_onExecuteReport);
  }

  Future<void> _onExecuteReport(
    ExecuteReport event,
    Emitter<ReportDetailState> emit,
  ) async {
    emit(state.copyWith(status: ReportDetailStatus.loading));

    try {
      final result = await _reportRepository.executeReport(
        event.report,
        event.filters,
      );

      if (result.isEmpty) {
        emit(
          state.copyWith(
            status: ReportDetailStatus.success,
            columns: [],
            rows: [],
          ),
        );
        return;
      }

      // Analyze data types from the first row
      final columnTypes = _analyzeColumnTypes(result['data'] as List);

      // Create columns with proper types and formatting
      final columns = _createColumns(
        result['data'].first as Map<String, dynamic>,
        columnTypes,
        event.report,
      );

      // Create rows with proper formatting
      final rows = _createRows(
        result['data'] as List<dynamic>,
        columns,
        columnTypes,
      );

      emit(
        state.copyWith(
          status: ReportDetailStatus.success,
          columns: columns,
          rows: rows,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ReportDetailStatus.failure, error: e.toString()),
      );
    }
  }

  Map<String, PlutoColumnType> _analyzeColumnTypes(List<dynamic> data) {
    final Map<String, PlutoColumnType> columnTypes = {};

    if (data.isEmpty) return columnTypes;

    final firstRow = data.first as Map<String, dynamic>;

    for (final key in firstRow.keys) {
      // Check data type across all rows
      bool isNumber = true;
      bool isDate = true;

      for (final row in data) {
        final value = row[key];
        if (value == null) continue;

        final stringValue = value.toString();

        // Check if it's a number
        if (isNumber && NumberFormatter.tryParse(stringValue) == null) {
          isNumber = false;
        }

        // Check if it's a date
        if (isDate && DateFormatter.tryParse(stringValue) == null) {
          isDate = false;
        }

        if (!isNumber && !isDate) break;
      }

      if (isDate) {
        columnTypes[key] = PlutoColumnType.date();
      } else if (isNumber) {
        columnTypes[key] = PlutoColumnType.number();
      } else {
        columnTypes[key] = PlutoColumnType.text();
      }
    }

    return columnTypes;
  }

  List<PlutoColumn> _createColumns(
    Map<String, dynamic> firstRow,
    Map<String, PlutoColumnType> columnTypes,
    dynamic report,
  ) {
    final displayOptions = report.displayOptions ?? {};
    final List<PlutoColumn> columns = [];
    final widthList = displayOptions['width-list'] as List? ?? [];
    final alignList = displayOptions['align-list'] as List? ?? [];
    final hideList = displayOptions['Hide'] as List? ?? [];

    int index = 0;
    for (final key in firstRow.keys) {
      // Skip hidden columns
      if (hideList.contains(index)) {
        index++;
        continue;
      }

      final type = columnTypes[key] ?? PlutoColumnType.text();

      columns.add(
        PlutoColumn(
          title: key,
          field: key,
          type: type,
          width: index < widthList.length ? widthList[index].toDouble() : 150,
          textAlign: _getTextAlign(type, alignList, index),
          formatter: _getColumnFormatter(type),
        ),
      );
      index++;
    }

    return columns;
  }

  List<PlutoRow> _createRows(
    List<dynamic> data,
    List<PlutoColumn> columns,
    Map<String, PlutoColumnType> columnTypes,
  ) {
    return data.map((row) {
      final cells = <String, PlutoCell>{};
      for (final column in columns) {
        final value = row[column.field];
        final type = columnTypes[column.field] ?? PlutoColumnType.text();

        cells[column.field] = PlutoCell(value: _formatCellValue(value, type));
      }
      return PlutoRow(cells: cells);
    }).toList();
  }

  PlutoColumnTextAlign _getTextAlign(
    PlutoColumnType type,
    List alignList,
    int index,
  ) {
    if (type == PlutoColumnType.number()) {
      return PlutoColumnTextAlign.right;
    }

    if (index < alignList.length) {
      return alignList[index] == 0
          ? PlutoColumnTextAlign.left
          : PlutoColumnTextAlign.right;
    }

    return PlutoColumnTextAlign.left;
  }

  String Function(dynamic)? _getColumnFormatter(PlutoColumnType type) {
    if (type == PlutoColumnType.number()) {
      return (dynamic value) =>
          NumberFormatter.formatDecimal(num.tryParse(value.toString()) ?? 0);
    }

    if (type == PlutoColumnType.date()) {
      return (dynamic value) {
        final date = DateFormatter.tryParse(value.toString());
        return date != null ? DateFormatter.formatDisplayDate(date) : '';
      };
    }

    return null;
  }

  dynamic _formatCellValue(dynamic value, PlutoColumnType type) {
    if (value == null) return '';

    if (type == PlutoColumnType.number()) {
      return num.tryParse(value.toString()) ?? value;
    }

    if (type == PlutoColumnType.date()) {
      final date = DateFormatter.tryParse(value.toString());
      return date ?? value;
    }

    return value.toString();
  }
}
