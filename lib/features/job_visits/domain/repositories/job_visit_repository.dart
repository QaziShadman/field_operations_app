import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;
import 'package:field_operations_app/features/job_visits/domain/entities/job_visit_sync_status.dart'
    as jobvisitwithsyncstatusentity;

abstract interface class JobVisitRepository {
  Future<entity.JobVisit> create(entity.JobVisit visit);

  Future<entity.JobVisit> update(entity.JobVisit visit);

  Future<entity.JobVisit?> getById(String id);

  // Stream<List<entity.JobVisit>> watchAll();

  Stream<List<jobvisitwithsyncstatusentity.JobVisitWithSyncStatus>> watchAll();
}
