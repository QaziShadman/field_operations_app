part of 'job_visit_bloc.dart';

sealed class JobVisitState {
  const JobVisitState();
}

final class JobVisitInitial extends JobVisitState {
  const JobVisitInitial();
}

final class JobVisitLoading extends JobVisitState {
  const JobVisitLoading();
}

final class JobVisitLoaded extends JobVisitState {
  const JobVisitLoaded({required this.visits});
  final List<entity.JobVisit> visits;
}

final class JobVisitFailure extends JobVisitState {
  const JobVisitFailure({required this.message});
  final String message;
}
