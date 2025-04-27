import 'package:flutter/material.dart';

class ReportFilterForm extends StatefulWidget {
  final Map<String, dynamic> filters;
  final Function(String, dynamic) onFilterChanged;

  const ReportFilterForm({
    super.key,
    required this.filters,
    required this.onFilterChanged,
  });

  @override
  State<ReportFilterForm> createState() => _ReportFilterFormState();
}

class _ReportFilterFormState extends State<ReportFilterForm> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize controllers for each filter
    if (widget.filters.containsKey('filter by')) {
      final filterList = widget.filters['filter by'] as List;
      for (final filter in filterList) {
        if (filter is Map<String, dynamic> && filter.containsKey('var-name')) {
          _controllers[filter['var-name']] = TextEditingController();
        }
      }
    }

    // Handle datetime filters
    if (widget.filters.containsKey('dateTime')) {
      final dateTimeFilters = widget.filters['dateTime'] as List;
      for (final filter in dateTimeFilters) {
        _controllers[filter] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Filters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ..._buildFilterFields(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilterFields() {
    final List<Widget> fields = [];

    // Build filter by fields
    if (widget.filters.containsKey('filter by')) {
      final filterList = widget.filters['filter by'] as List;
      for (final filter in filterList) {
        if (filter is Map<String, dynamic> && filter.containsKey('var-name')) {
          fields.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: _controllers[filter['var-name']],
                decoration: InputDecoration(
                  labelText: filter['var-name'],
                  border: const OutlineInputBorder(),
                ),
                onChanged:
                    (value) =>
                        widget.onFilterChanged(filter['var-name'], value),
              ),
            ),
          );
        }
      }
    }

    // Build datetime fields
    if (widget.filters.containsKey('dateTime')) {
      final dateTimeFilters = widget.filters['dateTime'] as List;
      for (final filter in dateTimeFilters) {
        fields.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextField(
              controller: _controllers[filter],
              decoration: InputDecoration(
                labelText: filter,
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _showDateTimePicker(filter),
            ),
          ),
        );
      }
    }

    return fields;
  }

  Future<void> _showDateTimePicker(String filterName) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        final formattedDateTime = dateTime.toString();
        _controllers[filterName]?.text = formattedDateTime;
        widget.onFilterChanged(filterName, formattedDateTime);
      }
    }
  }
}
