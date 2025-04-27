import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/report.dart';
import '../repositories/report_repository.dart';

// Events
abstract class ReportEvent {}

class LoadReports extends ReportEvent {}

class ExecuteReport extends ReportEvent {
  final int reportId;
  final Map<String, dynamic> filters;

  ExecuteReport(this.reportId, this.filters);
}

// States
abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportsLoaded extends ReportState {
  final List<Report> reports;
  ReportsLoaded(this.reports);
}

class ReportExecuted extends ReportState {
  final Map<String, dynamic> result;
  ReportExecuted(this.result);
}

class ReportError extends ReportState {
  final String message;
  ReportError(this.message);
}

// Bloc
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository repository;

  ReportBloc({required this.repository}) : super(ReportInitial()) {
    on<LoadReports>(_onLoadReports);
    on<ExecuteReport>(_onExecuteReport);
  }

  Future<void> _onLoadReports(
    LoadReports event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final reports = await repository.getReports();
      emit(ReportsLoaded(reports));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onExecuteReport(
    ExecuteReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final result = await repository.executeReport(
        event.reportId,
        event.filters,
      );
      emit(ReportExecuted(result));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
