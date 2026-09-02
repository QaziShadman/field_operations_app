import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;
import 'package:field_operations_app/features/job_visits/domain/enums/sync_status.dart';

class JobVisitWithSyncStatus {
  const JobVisitWithSyncStatus({required this.visit, required this.syncStatus});

  final entity.JobVisit visit;
  final SyncStatus syncStatus;
}
