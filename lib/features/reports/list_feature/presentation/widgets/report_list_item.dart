import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/models/report_config.dart';

class ReportListItem extends StatelessWidget {
  final ReportConfig report;
  final bool isSelected;

  const ReportListItem({
    super.key,
    required this.report,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(report.reportName),
      subtitle: Text(report.module ?? ''),
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      onTap:
          () => context.goNamed(
            'report-detail',
            pathParameters: {'id': report.id.toString()},
            extra: report,
          ),
      trailing: const Icon(Icons.arrow_forward_ios),
    );
  }
}
