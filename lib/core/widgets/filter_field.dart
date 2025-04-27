import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';

class FilterField extends StatelessWidget {
  final String label;
  final String? value;
  final bool isDateTime;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const FilterField({
    super.key,
    required this.label,
    this.value,
    this.isDateTime = false,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: isDateTime ? const Icon(Icons.calendar_today) : null,
          border: const OutlineInputBorder(),
          errorMaxLines: 2,
        ),
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value?.length ?? 0),
        readOnly: isDateTime,
        onTap: isDateTime ? () => _showDateTimePicker(context) : null,
        onChanged: isDateTime ? null : onChanged,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select $label date',
    );

    if (date == null || !context.mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select $label time',
    );

    if (time == null || !context.mounted) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    onChanged(DateFormatter.formatDateTime(dateTime));
  }
}
