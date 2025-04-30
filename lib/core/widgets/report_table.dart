import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../models/report_config.dart';
import '../utils/number_formatter.dart';
import 'report_search_field.dart';

class ReportTable extends StatefulWidget {
  final ReportConfig report;
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final bool showTotals;

  const ReportTable({
    super.key,
    required this.report,
    required this.columns,
    required this.rows,
    this.showTotals = true,
  });

  @override
  State<ReportTable> createState() => _ReportTableState();
}

class _ReportTableState extends State<ReportTable> {
  late PlutoGridStateManager stateManager;
  List<PlutoRow> totalRows = [];
  List<PlutoRow> filteredRows = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _updateFilteredRows();
  }

  @override
  void didUpdateWidget(ReportTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows != widget.rows) {
      _updateFilteredRows();
    }
  }

  void _updateFilteredRows() {
    if (_searchQuery.isEmpty) {
      filteredRows = widget.rows;
    } else {
      filteredRows = widget.rows.where((row) {
        return row.cells.values.any((cell) {
          final value = cell.value?.toString().toLowerCase() ?? '';
          return value.contains(_searchQuery.toLowerCase());
        });
      }).toList();
    }
    print('Rows after search: ${filteredRows.length}');
    _calculateTotals();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ReportSearchField(
            onSearch: (query) {
              print('Search query: $query');

              setState(() {
                _searchQuery = query;
                _updateFilteredRows();
              });
            },
          ),
        ),
        Expanded(
          child: PlutoGrid(
            columns: widget.columns.map((col) => col).toList(),
            rows: [...filteredRows, ...totalRows],
            onLoaded: (PlutoGridOnLoadedEvent event) {
              stateManager = event.stateManager;
              _calculateTotals();
            },
            onSorted: (PlutoGridOnSortedEvent event) {
              setState(() {
                _calculateTotals();
              });
            },
            configuration: const PlutoGridConfiguration(
              columnSize: PlutoGridColumnSizeConfig(
                autoSizeMode: PlutoAutoSizeMode.scale,
              ),
              style: PlutoGridStyleConfig(
                gridBorderColor: Colors.grey,
                gridBackgroundColor: Colors.white,
                rowHeight: 49,
                columnTextStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                // sortIconColor: Colors.black54,
                // sortIconSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _calculateTotals() {
    if (!widget.showTotals || widget.report.displayOptions == null) return;

    final totalsConfig = widget.report.displayOptions!['Totals'] as List?;
    if (totalsConfig == null || totalsConfig.isEmpty) return;

    final Map<String, num> totals = {};

    // Calculate totals for specified columns using filtered rows
    for (final row in filteredRows) {
      for (final column in widget.columns) {
        final colIndex = widget.columns.indexOf(column);
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

    // Create total row
    if (totals.isNotEmpty) {
      final cells = <String, PlutoCell>{};
      for (final column in widget.columns) {
        final value = totals[column.field];
        cells[column.field] = PlutoCell(
          value: value != null
              ? NumberFormatter.formatDecimal(value)
              : column.field == widget.columns.first.field
                  ? 'Total'
                  : '',
        );
      }

      setState(() {
        totalRows = [PlutoRow(cells: cells)];
      });
    } else {
      setState(() {
        totalRows = [];
      });
    }
  }
}
