part of 'job_visit_bloc.dart';

sealed class JobVisitEvent {
  const JobVisitEvent();
}

class JobVisitStarted extends JobVisitEvent {
  const JobVisitStarted();
}

class JobVisitCreated extends JobVisitEvent {
  const JobVisitCreated(this.visit);

  final entity.JobVisit visit;
}

class JobVisitUpdated extends JobVisitEvent {
  const JobVisitUpdated(this.visit);

  final entity.JobVisit visit;
}

class JobVisitsLoaded extends JobVisitEvent {
  const JobVisitsLoaded(this.visits);

  final List<entity.JobVisit> visits;
}

class JobVisitWatchFailed extends JobVisitEvent {
  const JobVisitWatchFailed(this.message);

  final String message;
}

class JobVisitConnectivityChanged extends JobVisitEvent {
  const JobVisitConnectivityChanged(this.isConnected);

  final bool isConnected;
}
