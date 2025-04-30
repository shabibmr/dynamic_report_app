import 'package:dynamic_report_app/features/reports/list_feature/bloc/report_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/models/report_config.dart';
import '../../../../../core/services/keyboard_shortcuts.dart';
import '../../../../../core/utils/report_exporter.dart';
import '../../../../../core/widgets/filter_field.dart';
import '../../../../../core/widgets/loader_overlay.dart';
import '../../../../../core/widgets/report_table.dart' show ReportTable;
import '../../../../../core/widgets/report_table_view.dart';
import '../../bloc/report_detail_bloc.dart';
import '../../../../../core/bloc/report_table_bloc.dart';

class ReportDetailPage extends StatefulWidget
    with RefreshableWidget, ExportableWidget, SearchableWidget {
  final ReportConfig report;
  late final _ReportDetailPageState? _state;

  ReportDetailPage({super.key, required this.report});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();

  @override
  VoidCallback? get onRefresh => _state?._executeReport;

  @override
  VoidCallback? get onExport => _state?._handleExport;

  @override
  VoidCallback? get onSearch => _state?._focusSearch;
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  final Map<String, dynamic> _filterValues = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget._state = this;
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    widget._state = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report.reportName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        elevation: 0,
        actions: [
          BlocBuilder<ReportDetailBloc, ReportDetailState>(
            builder: (context, state) {
              if (state.status == ReportDetailStatus.success) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Report (F5)',
                      onPressed: _executeReport,
                    ),
                    if (state.rows.isNotEmpty)
                      PopupMenuButton<ExportFormat>(
                        icon: const Icon(Icons.download),
                        tooltip: 'Export Report (Ctrl+E)',
                        onSelected: (format) => _exportReport(
                          state.columns.map((col) => col.title).toList(),
                          state.rows
                              .map(
                                (row) => row.cells.values
                                    .map((cell) => cell.value)
                                    .toList(),
                              )
                              .toList(),
                          format,
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: ExportFormat.excel,
                            child: Text('Export to Excel'),
                          ),
                          const PopupMenuItem(
                            value: ExportFormat.csv,
                            child: Text('Export to CSV'),
                          ),
                        ],
                      ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<ReportDetailBloc, ReportDetailState>(
        builder: (context, state) {
          print('ReportDetailBloc state: ${state.status}');
          if (state.status == ReportDetailStatus.loading) {
            return const LoaderOverlay(
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return LoaderOverlay(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilters(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _validateAndExecuteReport,
                      child: const Text('Generate - Report'),
                    ),
                  ),
                  if (state.status == ReportDetailStatus.success)
                    Expanded(
                      child: BlocProvider(
                        create: (context) => ReportTableBloc()
                          ..add(
                            InitializeReportTable(
                              report: widget.report,
                              columns: state.columns,
                              rows: state.rows,
                              showTotals: false,
                            ),
                          ),
                        child: ReportTableView(
                          report: widget.report,
                          columns: state.columns,
                          rows: state.rows,
                          showTotals: false,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    final dateTimeFilters = widget.report.filters?['dateTime'] as List? ?? [];
    final otherFilters = (widget.report.filters?['filter by'] as List? ?? [])
        .cast<Map<String, dynamic>>();

    return Builder(builder: (context) {
      // Check if the filters are empty from state
      final filters = context.select(
          (ReportListBloc bloc) => bloc.state.selectedReport?.filters ?? {});
      if (filters.isEmpty) {
        return const SizedBox.shrink();
      }

      return Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Report Filters',
              //   style: Theme.of(context).textTheme.titleLarge,
              // ),
              const SizedBox(height: 16),
              ...dateTimeFilters.map(
                (filterName) => FilterField(
                  label: filterName,
                  isDateTime: true,
                  value: _filterValues[filterName],
                  onChanged: (value) => setState(() {
                    _filterValues[filterName] = value;
                  }),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please select $filterName';
                    }
                    return null;
                  },
                ),
              ),
              ...otherFilters.map(
                (filter) => FilterField(
                  label: '${filter['var-name']} (${filter['var-value']})',
                  value: _filterValues[filter['var-name']],
                  onChanged: (value) => setState(() {
                    _filterValues[filter['var-name']] = value;
                  }),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter ${filter['var-name']}';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _validateAndExecuteReport() {
    if (_formKey.currentState?.validate() ?? false) {
      _executeReport();
    }
  }

  void _executeReport() {
    context.read<ReportDetailBloc>().add(
          ExecuteReport(
            report: widget.report,
          ),
        );
  }

  void _handleExport() {
    final state = context.read<ReportDetailBloc>().state;
    if (state.status == ReportDetailStatus.success && state.rows.isNotEmpty) {
      _exportReport(
        state.columns.map((col) => col.title).toList(),
        state.rows
            .map((row) => row.cells.values.map((cell) => cell.value).toList())
            .toList(),
        ExportFormat.excel, // Default to Excel export
      );
    }
  }

  Future<void> _exportReport(
    List<String> headers,
    List<List<dynamic>> rows,
    ExportFormat format,
  ) async {
    try {
      await ReportExporter.exportAndShare(
        reportName: widget.report.reportName,
        headers: headers,
        rows: rows,
        format: format,
        reportConfig: widget.report,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to export report: $e')));
      }
    }
  }

  void _focusSearch() {
    _searchFocusNode.requestFocus();
  }
}
