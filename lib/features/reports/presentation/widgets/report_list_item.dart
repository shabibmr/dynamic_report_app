import 'package:flutter/material.dart';
import '../../../../core/models/report_config.dart';

class ReportListItem extends StatelessWidget {
  final ReportConfig report;
  final bool isSelected;
  final VoidCallback onTap;

  const ReportListItem({
    super.key,
    required this.report,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(report.reportName),
      subtitle: Text(report.module ?? ''),
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios),
    );
  }
}
