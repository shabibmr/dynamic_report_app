import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/services/keyboard_shortcuts.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/error_boundary.dart';
import 'core/widgets/global_loader_overlay.dart';
import 'features/reports/detail_feature/bloc/report_detail_bloc.dart';
import 'features/reports/list_feature/bloc/report_list_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) => ReportListBloc(
                  reportRepository: ServiceLocator.instance.reportRepository,
                )..add(const LoadReportList()),
          ),
          BlocProvider(
            create:
                (context) => ReportDetailBloc(
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
