import 'package:flutter_test/flutter_test.dart';
import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart';
import 'package:field_operations_app/features/job_visits/domain/enums/job_visit_status.dart';
import 'package:field_operations_app/features/sync/domain/entities/job_visit_version.dart';
import 'package:field_operations_app/features/sync/domain/enums/job_visit_sync_field.dart';
import 'package:field_operations_app/features/sync/domain/services/job_visit_conflict_resolver.dart';
import 'package:field_operations_app/features/sync/domain/services/job_visit_merge_service.dart';

void main() {
  const resolver = JobVisitConflictResolver();
  const mergeService = JobVisitMergeService(conflictResolver: resolver);

  group('JobVisitConflictResolver.merge', () {
    test('throws when local and remote refer to different visits', () {
      final local = _version(
        id: 'visit-1',
        fieldVersions: {
          JobVisitSyncField.status: _fv('2026-01-01T10:00:00Z', 'device-a'),
        },
      );
      final remote = _version(
        id: 'visit-2',
        fieldVersions: {
          JobVisitSyncField.status: _fv('2026-01-01T11:00:00Z', 'device-b'),
        },
      );

      expect(
        () => resolver.merge(local, remote),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Cannot merge different Job Visits.',
          ),
        ),
      );
    });

    test('keeps the local value when local field version is newer', () {
      final local = _version(
        id: 'visit-1',
        status: JobVisitStatus.completed,
        fieldVersions: {
          JobVisitSyncField.status: _fv('2026-01-02T10:00:00Z', 'device-a'),
        },
      );
      final remote = _version(
        id: 'visit-1',
        status: JobVisitStatus.blocked,
        fieldVersions: {
          JobVisitSyncField.status: _fv('2026-01-01T10:00:00Z', 'device-b'),
        },
      );

      final merged = resolver.merge(local, remote);

      expect(merged.visit.status, JobVisitStatus.completed);
      expect(
        merged.fieldVersions[JobVisitSyncField.status],
        same(local.fieldVersions[JobVisitSyncField.status]),
      );
    });

    test('takes the remote value when remote field version is newer', () {
      final local = _version(
        id: 'visit-1',
        status: JobVisitStatus.completed,
        fieldVersions: {
          JobVisitSyncField.status: _fv('2026-01-01T10:00:00Z', 'device-a'),
        },
      );
      final remote = _version(
        id: 'visit-1',
        status: JobVisitStatus.blocked,
        fieldVersions: {
          JobVisitSyncField.status: _fv('2026-01-02T10:00:00Z', 'device-b'),
        },
      );

      final merged = resolver.merge(local, remote);

      expect(merged.visit.status, JobVisitStatus.blocked);
      expect(
        merged.fieldVersions[JobVisitSyncField.status],
        same(remote.fieldVersions[JobVisitSyncField.status]),
      );
    });

    test('uses remote value when local field version is missing', () {
      final local = _version(
        id: 'visit-1',
        status: JobVisitStatus.enRoute,
        fieldVersions: {},
      );
      final remote = _version(
        id: 'visit-1',
        status: JobVisitStatus.onSite,
        fieldVersions: {
          JobVisitSyncField.status: _fv('2026-01-02T10:00:00Z', 'device-b'),
        },
      );

      final merged = resolver.merge(local, remote);

      expect(merged.visit.status, JobVisitStatus.onSite);
      expect(
        merged.fieldVersions[JobVisitSyncField.status],
        same(remote.fieldVersions[JobVisitSyncField.status]),
      );
    });

    test('uses local value when remote field version is missing', () {
      final local = _version(
        id: 'visit-1',
        status: JobVisitStatus.onSite,
        fieldVersions: {
          JobVisitSyncField.status: _fv('2026-01-02T10:00:00Z', 'device-a'),
        },
      );
      final remote = _version(
        id: 'visit-1',
        status: JobVisitStatus.blocked,
        fieldVersions: {},
      );

      final merged = resolver.merge(local, remote);

      expect(merged.visit.status, JobVisitStatus.onSite);
      expect(
        merged.fieldVersions[JobVisitSyncField.status],
        same(local.fieldVersions[JobVisitSyncField.status]),
      );
    });

    test(
      'uses device id as deterministic tie-breaker for equal timestamps',
      () {
        final local = _version(
          id: 'visit-1',
          status: JobVisitStatus.completed,
          fieldVersions: {
            JobVisitSyncField.status: _fv('2026-01-02T10:00:00Z', 'device-a'),
          },
        );
        final remote = _version(
          id: 'visit-1',
          status: JobVisitStatus.blocked,
          fieldVersions: {
            JobVisitSyncField.status: _fv('2026-01-02T10:00:00Z', 'device-b'),
          },
        );

        final merged = resolver.merge(local, remote);

        expect(merged.visit.status, JobVisitStatus.blocked);
        expect(
          merged.fieldVersions[JobVisitSyncField.status],
          same(remote.fieldVersions[JobVisitSyncField.status]),
        );
      },
    );

    test(
      'keeps local value when timestamps tie and local device id sorts later',
      () {
        final local = _version(
          id: 'visit-1',
          status: JobVisitStatus.completed,
          fieldVersions: {
            JobVisitSyncField.status: _fv('2026-01-02T10:00:00Z', 'device-z'),
          },
        );
        final remote = _version(
          id: 'visit-1',
          status: JobVisitStatus.blocked,
          fieldVersions: {
            JobVisitSyncField.status: _fv('2026-01-02T10:00:00Z', 'device-a'),
          },
        );

        final merged = resolver.merge(local, remote);

        expect(merged.visit.status, JobVisitStatus.completed);
        expect(
          merged.fieldVersions[JobVisitSyncField.status],
          same(local.fieldVersions[JobVisitSyncField.status]),
        );
      },
    );

    test('resolves each field independently', () {
      final local = _version(
        id: 'visit-1',
        timestamp: DateTime.utc(2026, 1, 1, 10),
        latitude: 10.1,
        longitude: 20.1,
        status: JobVisitStatus.onSite,
        photoPath: 'local.jpg',
        fieldVersions: {
          JobVisitSyncField.timestamp: _fv('2026-01-03T10:00:00Z', 'device-a'),
          JobVisitSyncField.latitude: _fv('2026-01-01T10:00:00Z', 'device-a'),
          JobVisitSyncField.longitude: _fv('2026-01-03T10:00:00Z', 'device-a'),
          JobVisitSyncField.status: _fv('2026-01-01T10:00:00Z', 'device-a'),
          JobVisitSyncField.photoPath: _fv('2026-01-03T10:00:00Z', 'device-a'),
        },
      );

      final remote = _version(
        id: 'visit-1',
        timestamp: DateTime.utc(2026, 1, 2, 10),
        latitude: 11.2,
        longitude: 21.2,
        status: JobVisitStatus.completed,
        photoPath: 'remote.jpg',
        fieldVersions: {
          JobVisitSyncField.timestamp: _fv('2026-01-02T10:00:00Z', 'device-b'),
          JobVisitSyncField.latitude: _fv('2026-01-02T10:00:00Z', 'device-b'),
          JobVisitSyncField.longitude: _fv('2026-01-04T10:00:00Z', 'device-b'),
          JobVisitSyncField.status: _fv('2026-01-02T10:00:00Z', 'device-b'),
          JobVisitSyncField.photoPath: _fv('2026-01-02T10:00:00Z', 'device-b'),
        },
      );

      final merged = resolver.merge(local, remote);

      // timestamp -> local is newer
      expect(merged.visit.timestamp, local.visit.timestamp);

      // latitude -> remote is newer
      expect(merged.visit.latitude, remote.visit.latitude);

      // longitude -> remote is newer
      expect(merged.visit.longitude, remote.visit.longitude);

      // status -> remote is newer
      expect(merged.visit.status, remote.visit.status);

      // photoPath -> local is newer
      expect(merged.visit.photoPath, local.visit.photoPath);
    });

    test(
      'merges the field-version map by taking the newest version per field',
      () {
        final localStatus = _fv('2026-01-03T10:00:00Z', 'device-a');
        final remoteStatus = _fv('2026-01-04T10:00:00Z', 'device-b');
        final localLatitude = _fv('2026-01-05T10:00:00Z', 'device-a');
        final remoteLongitude = _fv('2026-01-06T10:00:00Z', 'device-b');

        final local = _version(
          id: 'visit-1',
          fieldVersions: {
            JobVisitSyncField.status: localStatus,
            JobVisitSyncField.latitude: localLatitude,
          },
        );
        final remote = _version(
          id: 'visit-1',
          fieldVersions: {
            JobVisitSyncField.status: remoteStatus,
            JobVisitSyncField.longitude: remoteLongitude,
          },
        );

        final merged = resolver.merge(local, remote);

        expect(merged.fieldVersions, hasLength(3));
        expect(
          merged.fieldVersions[JobVisitSyncField.status],
          same(remoteStatus),
        );
        expect(
          merged.fieldVersions[JobVisitSyncField.latitude],
          same(localLatitude),
        );
        expect(
          merged.fieldVersions[JobVisitSyncField.longitude],
          same(remoteLongitude),
        );
      },
    );

    test('does not mutate the local field-version map', () {
      final localVersion = _fv('2026-01-01T10:00:00Z', 'device-a');
      final remoteVersion = _fv('2026-01-02T10:00:00Z', 'device-b');

      final local = _version(
        id: 'visit-1',
        fieldVersions: {JobVisitSyncField.status: localVersion},
      );
      final remote = _version(
        id: 'visit-1',
        fieldVersions: {
          JobVisitSyncField.status: remoteVersion,
          JobVisitSyncField.latitude: _fv('2026-01-02T11:00:00Z', 'device-b'),
        },
      );

      resolver.merge(local, remote);

      expect(local.fieldVersions, hasLength(1));
      expect(local.fieldVersions[JobVisitSyncField.status], same(localVersion));
    });

    test(
      'preserves the visit id from the local visit after a successful merge',
      () {
        final local = _version(id: 'visit-123');
        final remote = _version(id: 'visit-123');

        final merged = resolver.merge(local, remote);

        expect(merged.visit.id, 'visit-123');
      },
    );
  });

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
