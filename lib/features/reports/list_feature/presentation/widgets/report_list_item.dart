import 'package:dynamic_report_app/features/reports/detail_feature/bloc/report_detail_bloc.dart';
import 'package:dynamic_report_app/features/reports/list_feature/bloc/report_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      onTap: () {
        context.read<ReportDetailBloc>().add(SetSelectedReport(report: report));
        context.read<ReportListBloc>().add(SelectReport(report.id));
        context.goNamed(
          'report-detail',
          pathParameters: {'id': report.id.toString()},
          extra: report,
        );
      },
      trailing: const Icon(Icons.arrow_forward_ios),
    );
  }
}
