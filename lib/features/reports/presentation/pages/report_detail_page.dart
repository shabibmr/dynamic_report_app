import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../../../../core/models/report_config.dart';
import '../../detail_feature/bloc/report_detail_bloc.dart';
import '../widgets/report_filter_form.dart';

class ReportDetailPage extends StatefulWidget {
  final ReportConfig report;

  const ReportDetailPage({super.key, required this.report});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  final Map<String, dynamic> _filterValues = {};
  PlutoGridStateManager? _stateManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.report.reportName)),
      body: BlocConsumer<ReportDetailBloc, ReportDetailState>(
        listener: (context, state) {
          if (state.status == ReportDetailStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error ?? 'An error occurred')),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              ReportFilterForm(
                filters: widget.report.filters ?? {},
                onFilterChanged: (key, value) {
                  setState(() {
                    _filterValues[key] = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _executeReport,
                  child: const Text('Generate Report'),
                ),
              ),
              Expanded(
                child:
                    state.status == ReportDetailStatus.loading
                        ? const Center(child: CircularProgressIndicator())
                        : PlutoGrid(
                          columns: state.columns,
                          rows: state.rows,
                          onLoaded: (PlutoGridOnLoadedEvent event) {
                            _stateManager = event.stateManager;
                          },
                          configuration: const PlutoGridConfiguration(
                            columnSize: PlutoGridColumnSizeConfig(
                              autoSizeMode: PlutoAutoSizeMode.scale,
                            ),
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _executeReport() {
    context.read<ReportDetailBloc>().add(
      ExecuteReport(report: widget.report, filters: _filterValues),
    );
  }
}
