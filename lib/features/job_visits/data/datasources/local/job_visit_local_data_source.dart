import 'package:field_operations_app/features/job_visits/data/models/job_visit_model.dart';
import 'package:field_operations_app/features/job_visits/data/models/job_visit_with_sync_status_model.dart';

abstract interface class JobVisitLocalDataSource {
  Future<void> create(JobVisitModel visit);

  Future<void> update(JobVisitModel visit, Set<String> changedFields);

  Future<JobVisitModel?> getById(String id);

  Stream<List<JobVisitModel>> watchAll();

  Stream<List<JobVisitWithSyncStatusModel>> watchAllWithSyncStatus();
}
