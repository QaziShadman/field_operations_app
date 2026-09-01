import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;

abstract interface class JobVisitRepository {
  Future<entity.JobVisit> create(entity.JobVisit visit);

  Future<entity.JobVisit> update(entity.JobVisit visit);

  Future<entity.JobVisit?> getById(String id);

  Stream<List<entity.JobVisit>> watchAll();
}
