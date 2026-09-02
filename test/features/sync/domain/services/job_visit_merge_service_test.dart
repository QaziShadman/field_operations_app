import 'package:flutter_test/flutter_test.dart';
import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart';
import 'package:field_operations_app/features/job_visits/domain/enums/job_visit_status.dart';
import 'package:field_operations_app/features/sync/domain/entities/job_visit_version.dart';
import 'package:field_operations_app/features/sync/domain/enums/job_visit_sync_field.dart';
import 'package:field_operations_app/features/sync/domain/services/job_visit_conflict_resolver.dart';
import 'package:field_operations_app/features/sync/domain/services/job_visit_merge_service.dart';

void main() {
  const mergeService = JobVisitMergeService(
    conflictResolver: JobVisitConflictResolver(),
  );

  group('JobVisitMergeService.merge', () {
    test('delegates merge behavior to the conflict resolver', () {
      final local = _version(
        id: 'visit-1',
        status: JobVisitStatus.onSite,
        fieldVersions: {
          JobVisitSyncField.status: _fv('2026-01-01T10:00:00Z', 'device-a'),
        },
      );
      final remote = _version(
        id: 'visit-1',
        status: JobVisitStatus.completed,
        fieldVersions: {
          JobVisitSyncField.status: _fv('2026-01-02T10:00:00Z', 'device-b'),
        },
      );

      final merged = mergeService.merge(local: local, remote: remote);

      expect(merged.visit.status, JobVisitStatus.completed);
      expect(
        merged.fieldVersions[JobVisitSyncField.status],
        same(remote.fieldVersions[JobVisitSyncField.status]),
      );
    });
  });
}

JobVisitVersion _version({
  required String id,
  DateTime? timestamp,
  double latitude = 0,
  double longitude = 0,
  JobVisitStatus status = JobVisitStatus.enRoute,
  String? photoPath,
  Map<JobVisitSyncField, FieldVersion>? fieldVersions,
}) {
  return JobVisitVersion(
    visit: JobVisit(
      id: id,
      timestamp: timestamp ?? DateTime.utc(2026, 1, 1, 9),
      latitude: latitude,
      longitude: longitude,
      status: status,
      photoPath: photoPath,
    ),
    fieldVersions: fieldVersions ?? const {},
  );
}

FieldVersion _fv(String updatedAt, String deviceId) {
  return FieldVersion(updatedAt: DateTime.parse(updatedAt), deviceId: deviceId);
}
