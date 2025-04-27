import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/bloc/report_bloc.dart';
import 'core/repositories/report_repository.dart';
import 'features/reports/report_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Reports',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => ReportBloc(
          repository: ReportRepository(
            baseUrl:
                'http://localhost/api', // Adjust this to match your PHP server URL
          ),
        )..add(LoadReports()),
        child: const ReportListScreen(),
      ),
    );
  }
}
