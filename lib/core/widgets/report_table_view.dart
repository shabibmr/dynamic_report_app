import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../../features/reports/detail_feature/bloc/report_detail_bloc.dart';
import '../bloc/report_table_bloc.dart';
import '../models/report_config.dart';
import 'report_search_field.dart';

class ReportTableView extends StatelessWidget {
  final ReportConfig report;
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final bool showTotals;

  const ReportTableView({
    super.key,
    required this.report,
    required this.columns,
    required this.rows,
    this.showTotals = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<ReportTableBloc>(),
      child: const ReportTableContent(),
    );
  }
}

class ReportTableContent extends StatefulWidget {
  const ReportTableContent({super.key});

  @override
  State<ReportTableContent> createState() => _ReportTableContentState();
}

class _ReportTableContentState extends State<ReportTableContent> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final dStatus =
          context.select((ReportDetailBloc bloc) => bloc.state.status);
      return BlocBuilder<ReportTableBloc, ReportTableState>(
        buildWhen: (previous, current) =>
            current.isLoading == false ||
            previous.isLoading != current.isLoading,
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ReportSearchField(
                  onSearch: (query) {
                    context
                        .read<ReportTableBloc>()
                        .add(SearchReportTable(query));
                  },
                ),
              ),
              Expanded(
                child: PlutoGrid(
                  key: UniqueKey(),
                  columns: state.columns,
                  rows: [
                    ...state.filteredRows,
                    if (state.showTotals) ...state.totalRows,
                  ],
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    // Grid loaded event handling if needed
                    print(
                        'Grid loaded with ${event.stateManager.rows.length} rows');
                  },
                  onSorted: (PlutoGridOnSortedEvent event) {
                    context.read<ReportTableBloc>().add(
                          SortReportTable(
                            columnField: event.column.field,
                            ascending:
                                event.column.sort == PlutoColumnSort.ascending,
                          ),
                        );
                  },
                  configuration: const PlutoGridConfiguration(
                    columnFilter: PlutoGridColumnFilterConfig(),
                    columnSize: PlutoGridColumnSizeConfig(
                      autoSizeMode: PlutoAutoSizeMode.scale,
                      resizeMode: PlutoResizeMode.pushAndPull,
                    ),
                    style: PlutoGridStyleConfig(
                      iconSize: 0,
                      gridBorderColor: Colors.grey,
                      gridBackgroundColor: Colors.white,
                      rowHeight: 49,
                      columnTextStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
