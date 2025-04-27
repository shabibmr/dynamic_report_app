import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/reports/list_feature/presentation/pages/report_list_page.dart';
import '../../features/reports/detail_feature/presentation/pages/report_detail_page.dart';
import '../../core/models/report_config.dart';
import '../../core/error/error_handler.dart';
import '../../core/di/service_locator.dart';
import 'router_notifier.dart';

final routerNotifier = RouterNotifier(ServiceLocator.instance.reportRepository);

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: routerNotifier,
  debugLogDiagnostics: true, // Helpful for development
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => child,
      routes: [
        GoRoute(
          path: '/',
          name: 'reports',
          builder: (context, state) => ReportListPage(),
          routes: [
            GoRoute(
              path: 'report/:id',
              name: 'report-detail',
              builder: (context, state) {
                final report =
                    state.extra as ReportConfig? ??
                    routerNotifier.getReportById(
                      int.parse(state.pathParameters['id'] ?? '0'),
                    );

                if (report == null) {
                  throw const RouteException('Report not found');
                }

                // Parse filters from query parameters if they exist
                final filterJson = state.uri.queryParameters['filters'];
                final filters =
                    filterJson != null
                        ? Map<String, dynamic>.from(jsonDecode(filterJson))
                        : <String, dynamic>{};

                return ReportDetailPage(
                  report: report,
                  // initialFilters: filters,
                );
              },
              redirect: (context, state) {
                try {
                  final report =
                      state.extra as ReportConfig? ??
                      routerNotifier.getReportById(
                        int.parse(state.pathParameters['id'] ?? '0'),
                      );

                  if (report?.redirectTo != null) {
                    final redirect = report!.redirectTo as Map<String, dynamic>;
                    final defaultRedirect = redirect['default'];
                    if (defaultRedirect != null) {
                      final targetReportId = defaultRedirect['id'];
                      if (targetReportId != null) {
                        // Preserve any filter parameters during redirect
                        final currentUri = state.uri;
                        return '/report/$targetReportId${currentUri.query.isEmpty ? '' : '?${currentUri.query}'}';
                      }
                    }
                  }
                  return null;
                } catch (e, stackTrace) {
                  ErrorHandler.logError(
                    'Failed to process report redirect',
                    e,
                    stackTrace,
                  );
                  return '/';
                }
              },
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: BackButton(onPressed: () => context.go('/')),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  state.error?.toString() ?? 'An unknown error occurred',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Return to Reports List'),
                ),
              ],
            ),
          ),
        ),
      ),
);

class RouteException implements Exception {
  final String message;
  const RouteException(this.message);

  @override
  String toString() => message;
}
