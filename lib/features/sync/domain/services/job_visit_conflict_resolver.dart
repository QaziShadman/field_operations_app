import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as jobvisitentity;
import 'package:field_operations_app/features/sync/domain/entities/job_visit_version.dart'
    as jobvisitversionentity;
import 'package:field_operations_app/features/sync/domain/enums/job_visit_sync_field.dart';

class JobVisitConflictResolver {
  const JobVisitConflictResolver();

  jobvisitversionentity.JobVisitVersion merge(
    jobvisitversionentity.JobVisitVersion local,
    jobvisitversionentity.JobVisitVersion remote,
  ) {
    if (local.visit.id != remote.visit.id) {
      throw ArgumentError('Cannot merge different Job Visits.');
    }

    return jobvisitversionentity.JobVisitVersion(
      visit: jobvisitentity.JobVisit(
        id: local.visit.id,
        timestamp: _resolveField(
          field: JobVisitSyncField.timestamp,
          local: local,
          remote: remote,
          localValue: local.visit.timestamp,
          remoteValue: remote.visit.timestamp,
        ),
        latitude: _resolveField(
          field: JobVisitSyncField.latitude,
          local: local,
          remote: remote,
          localValue: local.visit.latitude,
          remoteValue: remote.visit.latitude,
        ),
        longitude: _resolveField(
          field: JobVisitSyncField.longitude,
          local: local,
          remote: remote,
          localValue: local.visit.longitude,
          remoteValue: remote.visit.longitude,
        ),
        status: _resolveField(
          field: JobVisitSyncField.status,
          local: local,
          remote: remote,
          localValue: local.visit.status,
          remoteValue: remote.visit.status,
        ),
        photoPath: _resolveField(
          field: JobVisitSyncField.photoPath,
          local: local,
          remote: remote,
          localValue: local.visit.photoPath,
          remoteValue: remote.visit.photoPath,
        ),
      ),
      fieldVersions: _mergeVersions(local, remote),
    );
  }

  T _resolveField<T>({
    required JobVisitSyncField field,
    required jobvisitversionentity.JobVisitVersion local,
    required jobvisitversionentity.JobVisitVersion remote,
    required T localValue,
    required T remoteValue,
  }) {
    final localVersion = local.fieldVersions[field];
    final remoteVersion = remote.fieldVersions[field];

    if (localVersion == null) {
      return remoteValue;
    }

    if (remoteVersion == null) {
      return localValue;
    }

    if (_isRemoteNewer(localVersion, remoteVersion)) {
      return remoteValue;
    }

    return localValue;
  }

  Map<JobVisitSyncField, jobvisitversionentity.FieldVersion> _mergeVersions(
    jobvisitversionentity.JobVisitVersion local,
    jobvisitversionentity.JobVisitVersion remote,
  ) {
    final merged = <JobVisitSyncField, jobvisitversionentity.FieldVersion>{
      ...local.fieldVersions,
    };

    for (final entry in remote.fieldVersions.entries) {
      final localVersion = merged[entry.key];

      if (localVersion == null || _isRemoteNewer(localVersion, entry.value)) {
        merged[entry.key] = entry.value;
      }
    }

    return merged;
  }

  bool _isRemoteNewer(
    jobvisitversionentity.FieldVersion local,
    jobvisitversionentity.FieldVersion remote,
  ) {
    if (remote.updatedAt.isAfter(local.updatedAt)) {
      return true;
    }

    if (remote.updatedAt.isBefore(local.updatedAt)) {
      return false;
    }

    return remote.deviceId.compareTo(local.deviceId) > 0;
  }
}
