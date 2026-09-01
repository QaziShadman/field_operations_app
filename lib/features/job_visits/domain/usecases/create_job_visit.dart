import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;
import 'package:field_operations_app/features/job_visits/domain/repositories/job_visit_repository.dart';

class CreateJobVisit {
  const CreateJobVisit({required this._repository});

  final JobVisitRepository _repository;

  Future<entity.JobVisit> call(entity.JobVisit visit) {
    return _repository.create(visit);
  }
}
