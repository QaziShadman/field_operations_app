import 'package:field_operations_app/database/app_database.dart' as db;
import 'package:field_operations_app/features/job_visits/data/models/job_visit_model.dart';
import 'package:field_operations_app/features/job_visits/domain/entities/job_visit_sync_status.dart'
    as jobvisitwithsyncstatusentity;
import 'package:field_operations_app/features/job_visits/domain/enums/sync_status.dart';

class JobVisitWithSyncStatusModel {
  const JobVisitWithSyncStatusModel({
    required this.visit,
    required this.syncStatus,
  });

  final JobVisitModel visit;
  final SyncStatus syncStatus;

  jobvisitwithsyncstatusentity.JobVisitWithSyncStatus toEntity() {
    return jobvisitwithsyncstatusentity.JobVisitWithSyncStatus(
      visit: visit.toEntity(),
      syncStatus: syncStatus,
    );
  }

  factory JobVisitWithSyncStatusModel.fromDatabase({
    required db.JobVisit jobVisit,
    db.SyncOperation? syncOperation,
  }) {
    return JobVisitWithSyncStatusModel(
      visit: JobVisitModel.fromDatabase(jobVisit),
      syncStatus: _mapSyncStatus(syncOperation?.state),
    );
  }

  static SyncStatus _mapSyncStatus(String? state) {
    return switch (state) {
      "pending" => SyncStatus.pending,
      "inProgress" => SyncStatus.syncing,
      "completed" => SyncStatus.synced,
      "failed" => SyncStatus.failed,
      null => SyncStatus.synced,
      _ => SyncStatus.synced,
    };
  }
}
