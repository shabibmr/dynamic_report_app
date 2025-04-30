/// A screen widget that handles the execution of dynamic reports with configurable filters.
/// This screen provides a user interface for:
/// 1. Displaying and configuring report filters
/// 2. Executing the report with the selected filter values
/// 3. Displaying the report results in a data table format
///
/// The screen works with three main components:
/// - Filter inputs: Generated dynamically based on the report configuration
/// - Execute button: Triggers the report execution
/// - Results display: Shows the report data in a scrollable table
import 'package:dynamic_report_app/features/reports/detail_feature/bloc/report_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/report_config.dart';
import 'list_feature/bloc/report_list_bloc.dart';

/// A StatefulWidget that represents the report execution interface.
/// Takes a [ReportConfig] object that defines the report structure and filters.
class ReportExecutionScreen extends StatefulWidget {
  /// The report configuration containing filter definitions and display options
  final ReportConfig report;

  const ReportExecutionScreen({super.key, required this.report});

  @override
  State<ReportExecutionScreen> createState() => _ReportExecutionScreenState();
}

/// The state class for ReportExecutionScreen.
/// Manages:
/// - Text controllers for filter inputs
/// - Report execution state
/// - Report data display
class _ReportExecutionScreenState extends State<ReportExecutionScreen> {
  /// Map of filter names to their corresponding TextEditingControllers
  /// Used to manage the state of filter input fields
  final Map<String, TextEditingController> _controllers = {};

  /// Stores the report execution results
  /// null when no report has been executed yet
  Map<String, dynamic>? _reportData;

  /// Initializes the controllers for all filter fields defined in the report configuration.
  /// Creates TextEditingController instances for:
  /// - Standard filters from 'filter by' section
  /// - DateTime filters from 'dateTime' section
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

  /// Cleans up resources by disposing all TextEditingControllers
  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  /// Executes the report with the current filter values.
  /// Collects all filter values from controllers and dispatches an ExecuteReport event
  /// to the ReportDetailBloc.
  Future<void> _executeReport() async {
    // final filters = <String, dynamic>{};
    // _controllers.forEach((key, controller) {
    //   filters['\$$key'] = controller.text;
    // });

    context.read<ReportDetailBloc>().add(ExecuteReport(report: widget.report));
  }

  /// Builds the filter input section of the screen.
  /// Creates input fields for:
  /// - Standard text filters with OutlineInputBorder
  /// - DateTime filters with calendar picker icon
  /// Returns a Column widget containing all filter inputs
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

  /// Builds the results section displaying the report data.
  /// - Shows a DataTable if data is available
  /// - Handles empty data case
  /// - Implements horizontal and vertical scrolling for large datasets
  /// Returns a widget tree containing the results table or empty state
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

  /// Shows a combined date and time picker dialog.
  /// First shows date picker, then time picker if date was selected.
  /// Returns a DateTime object combining the selected date and time,
  /// or null if either selection was cancelled.
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

  /// Builds the main screen layout with:
  /// - AppBar showing report name
  /// - Filter section
  /// - Execute button
  /// - Results section with loading state handling
  /// - Error handling through BlocListener
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report.reportName),
      ),
      body: BlocListener<ReportDetailBloc, ReportDetailState>(
        listener: (context, state) {
          if (state.status == ReportDetailStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error ?? 'An error occurred')),
            );
          } else if (state.status == ReportDetailStatus.success) {
            // setState(() => _reportData = state.result);
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
                child: BlocBuilder<ReportDetailBloc, ReportDetailState>(
                  builder: (context, state) {
                    if (state.status == ReportDetailStatus.loading) {
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
