import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../list_feature/bloc/report_list_bloc.dart';
import '../widgets/report_list_item.dart';

class ReportListPage extends StatelessWidget {
  const ReportListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: BlocBuilder<ReportListBloc, ReportListState>(
        builder: (context, state) {
          switch (state.status) {
            case ReportListStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case ReportListStatus.failure:
              return Center(
                child: Text(state.error ?? 'Failed to load reports'),
              );

            case ReportListStatus.success:
              if (state.reports.isEmpty) {
                return const Center(child: Text('No reports found'));
              }

              return ListView.builder(
                itemCount: state.reports.length,
                itemBuilder: (context, index) {
                  final report = state.reports[index];
                  return ReportListItem(
                    report: report,
                    isSelected: state.selectedReport?.id == report.id,
                    onTap:
                        () => context.read<ReportListBloc>().add(
                          SelectReport(report.id),
                        ),
                  );
                },
              );

            case ReportListStatus.initial:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
