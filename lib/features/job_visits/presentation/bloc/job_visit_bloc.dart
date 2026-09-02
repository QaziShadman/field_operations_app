import 'dart:async';

import 'package:field_operations_app/core/utils/services/connectivity/connectivity_service.dart';
import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;
import 'package:field_operations_app/features/job_visits/domain/usecases/create_job_visit.dart';
import 'package:field_operations_app/features/job_visits/domain/usecases/update_job_visit.dart';
import 'package:field_operations_app/features/job_visits/domain/usecases/watch_job_visits.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

part 'job_visit_event.dart';
part 'job_visit_state.dart';

class JobVisitBloc extends Bloc<JobVisitEvent, JobVisitState> {
  JobVisitBloc({
    required this._watchJobVisits,
    required this._createJobVisit,
    required this._updateJobVisit,
    required this._connectivity,
  }) : super(const JobVisitInitial()) {
    on<JobVisitStarted>(_onStarted);
    on<JobVisitCreated>(_onCreated);
    on<JobVisitUpdated>(_onUpdated);
    on<JobVisitsLoaded>(_onJobsLoaded);
    on<JobVisitWatchFailed>(_onWatchFailed);
    on<JobVisitConnectivityChanged>(_onConnectivityChanged);
  }
  final WatchJobVisits _watchJobVisits;
  final CreateJobVisit _createJobVisit;
  final UpdateJobVisit _updateJobVisit;
  final ConnectivityServices _connectivity;

  StreamSubscription<List<entity.JobVisit>>? _watchSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  Future<void> _onStarted(
    JobVisitStarted event,
    Emitter<JobVisitState> emit,
  ) async {
    emit(const JobVisitLoading());

    // Check the initial internet connection.
    await _connectivity.startMonitoring();

    debugPrint('Initial connection: ${_connectivity.isConnected}');

    // Listen for future connectivity changes.
    await _connectivitySubscription?.cancel();

    _connectivitySubscription = _connectivity.connectionStream.listen((
      isConnected,
    ) {
      add(JobVisitConnectivityChanged(isConnected));
    });

    await _watchSubscription?.cancel();

    _watchSubscription = _watchJobVisits().listen(
      (visits) => add(JobVisitsLoaded(visits)),
      onError: (Object error) {
        add(JobVisitWatchFailed(error.toString()));
      },
    );
  }

  Future<void> _onCreated(
    JobVisitCreated event,
    Emitter<JobVisitState> emit,
  ) async {
    try {
      await _createJobVisit.call(event.visit);
    } catch (error) {
      emit(JobVisitFailure(message: 'Unable to create job visit: $error'));
    }
  }

  Future<void> _onUpdated(
    JobVisitUpdated event,
    Emitter<JobVisitState> emit,
  ) async {
    try {
      await _updateJobVisit.call(event.visit);
    } catch (error) {
      emit(JobVisitFailure(message: 'Unable to update job visit: $error'));
    }
  }

  void _onJobsLoaded(JobVisitsLoaded event, Emitter<JobVisitState> emit) {
    emit(JobVisitLoaded(visits: event.visits));
  }

  void _onWatchFailed(JobVisitWatchFailed event, Emitter<JobVisitState> emit) {
    emit(JobVisitFailure(message: event.message));
  }

  void _onConnectivityChanged(
    JobVisitConnectivityChanged event,
    Emitter<JobVisitState> emit,
  ) {
    if (event.isConnected) {
      debugPrint('Internet connection restored');
    } else {
      debugPrint('Internet connection lost');
    }
  }

  @override
  Future<void> close() async {
    await _connectivitySubscription?.cancel();
    await _watchSubscription?.cancel();
    await _connectivity.dispose();
    return super.close();
  }
}
