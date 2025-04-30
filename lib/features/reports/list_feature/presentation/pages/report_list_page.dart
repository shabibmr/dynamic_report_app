import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/keyboard_shortcuts.dart';
import '../../../../../core/widgets/error_boundary.dart';
import '../../bloc/report_list_bloc.dart';
import '../widgets/report_list_item.dart';
import '../widgets/report_search_bar.dart';

class ReportListPage extends StatefulWidget
    with RefreshableWidget, SearchableWidget {
  final _ReportListPageState? _state;

  ReportListPage({super.key}) : _state = null;

  @override
  State<ReportListPage> createState() => _ReportListPageState();

  @override
  VoidCallback? get onRefresh => _state?._handleRefresh;

  @override
  VoidCallback? get onSearch => _state?._focusSearch;
}

class _ReportListPageState extends State<ReportListPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleRefresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportListBloc, ReportListState>(
      listener: (context, state) {
        if(state.status == ReportListStatus.success){}
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic Reports'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh List (F5)',
              onPressed: _handleRefresh,
            ),
          ],
        ),
        body: ErrorBoundary(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReportSearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (query) {
                    context.read<ReportListBloc>().add(SearchReports(query));
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<ReportListBloc, ReportListState>(
                  builder: (context, state) {
                    if (state.status == ReportListStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == ReportListStatus.failure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Failed to load reports'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _handleRefresh,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

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
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRefresh() {
    context.read<ReportListBloc>().add(const LoadReportList());
  }

  void _focusSearch() {
    _searchFocusNode.requestFocus();
  }
}
