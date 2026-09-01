import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;
import 'package:field_operations_app/features/job_visits/domain/repositories/job_visit_repository.dart';

class WatchJobVisits {
  const WatchJobVisits({required this._repository});

  final JobVisitRepository _repository;

  Stream<List<entity.JobVisit>> call() {
    return _repository.watchAll();
  }
}
