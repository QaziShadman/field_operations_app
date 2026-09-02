import 'package:field_operations_app/features/sync/domain/entities/job_visit_version.dart'
    as entity;

abstract interface class JobVisitVersionLocalDataSource {
  Future<entity.JobVisitVersion?> getById(String visitId);

  Future<void> save(entity.JobVisitVersion visit);
}
