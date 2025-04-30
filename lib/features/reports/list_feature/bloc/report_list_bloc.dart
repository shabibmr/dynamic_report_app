import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/repositories/report_repository.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/report_config.dart';

part 'report_list_event.dart';
part 'report_list_state.dart';

class ReportListBloc extends Bloc<ReportListEvent, ReportListState> {
  final ReportRepository _reportRepository;

  ReportListBloc({required ReportRepository reportRepository})
      : _reportRepository = reportRepository,
        super(const ReportListState()) {
    on<LoadReportList>(_onLoadReportList);
    on<SelectReport>(_onSelectReport);
    on<SearchReports>(_onSearchReports);
  }

  Future<void> _onLoadReportList(
    LoadReportList event,
    Emitter<ReportListState> emit,
  ) async {
    emit(state.copyWith(status: ReportListStatus.loading));

    try {
      final reports = await _reportRepository.getReports();
      emit(
        state.copyWith(
          status: ReportListStatus.success,
          reports: reports,
          // filteredReports: reports,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ReportListStatus.failure, error: e.toString()),
      );
    }
  }

  void _onSelectReport(SelectReport event, Emitter<ReportListState> emit) {
    if ((state.selectedReport?.id ?? 0) == event.reportId) {
      return;
    }
    final selectedReport = state.reports.firstWhere(
      (report) => report.id == event.reportId,
      orElse: () => state.selectedReport!,
    );

    emit(state.copyWith(selectedReport: selectedReport));
  }

  void _onSearchReports(SearchReports event, Emitter<ReportListState> emit) {
    if (event.query.isEmpty) {
      emit(state.copyWith(reports: state.reports));
      return;
    }

    final filteredReports = state.reports.where((report) {
      final searchLower = event.query.toLowerCase();
      final nameLower = report.reportName.toLowerCase();
      final moduleLower = report.module?.toLowerCase() ?? '';

      return nameLower.contains(searchLower) ||
          moduleLower.contains(searchLower);
    }).toList();

    emit(state.copyWith(reports: filteredReports));
  }
}
