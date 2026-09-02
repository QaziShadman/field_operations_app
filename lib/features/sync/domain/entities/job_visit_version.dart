import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;
import 'package:field_operations_app/features/sync/domain/enums/job_visit_sync_field.dart';

class JobVisitVersion {
  const JobVisitVersion({required this.visit, required this.fieldVersions});

  final entity.JobVisit visit;
  final Map<JobVisitSyncField, FieldVersion> fieldVersions;
}

class FieldVersion {
  const FieldVersion({required this.updatedAt, required this.deviceId});

  final DateTime updatedAt;
  final String deviceId;
}
