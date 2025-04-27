import 'package:flutter/material.dart';

class ReportFilterForm extends StatelessWidget {
  final Map<String, dynamic> filters;
  final Function(String, dynamic) onFilterChanged;

  const ReportFilterForm({
    super.key,
    required this.filters,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateTimeFilters = filters['dateTime'] as List? ?? [];
    final otherFilters =
        (filters['filter by'] as List? ?? []).cast<Map<String, dynamic>>();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Filters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...dateTimeFilters.map(
              (filterName) => _buildDateTimeField(context, filterName),
            ),
            ...otherFilters.map(
              (filter) => _buildFilterField(
                context,
                filter['var-name'] as String,
                filter['var-value'] as String,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeField(BuildContext context, String filterName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: filterName,
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? picked = await showDateTimePicker(
                  context,
                  filterName,
                );
                if (picked != null) {
                  onFilterChanged(filterName, picked.toIso8601String());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField(
    BuildContext context,
    String varName,
    String varValue,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: '$varName ($varValue)'),
        onChanged: (value) => onFilterChanged(varName, value),
      ),
    );
  }

  Future<DateTime?> showDateTimePicker(
    BuildContext context,
    String title,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return null;

    if (!context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
