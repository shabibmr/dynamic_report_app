import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/report_bloc.dart';
import '../../core/models/report.dart';
import 'report_execution_screen.dart';

class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsLoaded) {
            return ListView.builder(
              itemCount: state.reports.length,
              itemBuilder: (context, index) {
                final report = state.reports[index];
                return ListTile(
                  title: Text(report.reportName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReportExecutionScreen(report: report),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is ReportError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ReportBloc>().add(LoadReports());
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
