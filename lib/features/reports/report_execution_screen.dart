import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/report_bloc.dart';
import '../../core/models/report.dart';

class ReportExecutionScreen extends StatefulWidget {
  final Report report;

  const ReportExecutionScreen({super.key, required this.report});

  @override
  State<ReportExecutionScreen> createState() => _ReportExecutionScreenState();
}

class _ReportExecutionScreenState extends State<ReportExecutionScreen> {
  final Map<String, TextEditingController> _controllers = {};
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    if (widget.report.filters != null) {
      final filterData = widget.report.filters!;
      if (filterData['filter by'] != null) {
        for (var filter in filterData['filter by']) {
          _controllers[filter['var-name']] = TextEditingController();
        }
      }
      if (filterData['dateTime'] != null) {
        for (var dateField in filterData['dateTime']) {
          _controllers[dateField] = TextEditingController();
        }
      }
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _executeReport() async {
    final filters = <String, dynamic>{};
    _controllers.forEach((key, controller) {
      filters['\$$key'] = controller.text;
    });

    context.read<ReportBloc>().add(ExecuteReport(widget.report.id, filters));
  }

  Widget _buildFilters() {
    final widgets = <Widget>[];

    if (widget.report.filters != null) {
      final filterData = widget.report.filters!;

      // Handle standard filters
      if (filterData['filter by'] != null) {
        for (var filter in filterData['filter by']) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controllers[filter['var-name']],
                decoration: InputDecoration(
                  labelText: filter['var-name'],
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          );
        }
      }

      // Handle datetime filters
      if (filterData['dateTime'] != null) {
        for (var dateField in filterData['dateTime']) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controllers[dateField],
                decoration: InputDecoration(
                  labelText: dateField,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDateTimePicker(context);
                      if (date != null) {
                        _controllers[dateField]?.text = date
                            .toIso8601String()
                            .split('.')[0]; // Format: YYYY-MM-DD HH:mm:ss
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return Column(children: widgets);
  }

  Widget _buildResults() {
    if (_reportData == null) return const SizedBox.shrink();

    final displayOptions =
        _reportData!['display_options'] as Map<String, dynamic>?;
    final data = _reportData!['data'] as List<dynamic>;

    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final columns = data[0].keys.toList();
    final rows = data.map((row) => row.values.toList()).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: columns
              .map((col) => DataColumn(label: Text(col.toString())))
              .toList(),
          rows: rows.map((row) {
            return DataRow(
              cells:
                  row.map((cell) => DataCell(Text(cell.toString()))).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<DateTime?> showDateTimePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report.reportName),
      ),
      body: BlocListener<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ReportExecuted) {
            setState(() => _reportData = state.result);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFilters(),
              ElevatedButton(
                onPressed: _executeReport,
                child: const Text('Execute Report'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<ReportBloc, ReportState>(
                  builder: (context, state) {
                    if (state is ReportLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildResults();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
