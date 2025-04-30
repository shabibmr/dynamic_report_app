/// Root application widget that sets up the application's core infrastructure.
/// This includes:
/// - Error boundaries for graceful error handling
/// - BLoC providers for state management
/// - Material app configuration with routing and theming
/// - Global loader overlay for loading states
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/error_boundary.dart';
import 'core/widgets/global_loader_overlay.dart';
// import 'core/bloc/report_bloc.dart';
import 'features/reports/detail_feature/bloc/report_detail_bloc.dart';
import 'features/reports/list_feature/bloc/report_list_bloc.dart';

/// The root application widget that configures the app-wide services and UI.
class App extends StatelessWidget {
  /// Creates an instance of the App widget.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: MultiBlocProvider(
        providers: [
          // Main report bloc for handling report execution and management
          // BlocProvider(
          //   create: (context) => ReportBloc(
          //     repository: ServiceLocator.instance.reportRepository,
          //   )..add(LoadReports()),
          // ),
          // Report list bloc for managing the list of available reports
          BlocProvider(
            create: (context) => ReportListBloc(
              reportRepository: ServiceLocator.instance.reportRepository,
            )..add(const LoadReportList()),
          ),
          // Report detail bloc for managing individual report configuration
          BlocProvider(
            create: (context) => ReportDetailBloc(
              reportRepository: ServiceLocator.instance.reportRepository,
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'Dynamic Reports',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          routerConfig: appRouter,
          builder: (context, child) {
            return ErrorBoundary(
              child: GlobalLoaderOverlay(child: child ?? const SizedBox()),
            );
          },
        ),
      ),
    );
  }
}
