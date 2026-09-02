import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as jobvisitentity;
import 'package:field_operations_app/features/job_visits/domain/enums/job_visit_status.dart';
import 'package:field_operations_app/features/sync/domain/entities/job_visit_version.dart'
    as jobvisitversionentity;
import 'package:field_operations_app/features/sync/domain/enums/job_visit_sync_field.dart';

class RemoteJobVisitModel {
  const RemoteJobVisitModel({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.photoPath,
    required this.fieldVersions,
  });

  final String id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final JobVisitStatus status;
  final String? photoPath;
  final Map<JobVisitSyncField, jobvisitversionentity.FieldVersion>
  fieldVersions;

  factory RemoteJobVisitModel.fromJson(Map<String, dynamic> json) {
    final rawVersions = json['fieldVersions'] as Map<String, dynamic>? ?? {};

    final fieldVersions =
        <JobVisitSyncField, jobvisitversionentity.FieldVersion>{};

    for (final entry in rawVersions.entries) {
      final field = JobVisitSyncField.values.byName(entry.key);
      final value = entry.value as Map<String, dynamic>;

      fieldVersions[field] = jobvisitversionentity.FieldVersion(
        updatedAt: DateTime.parse(value['updatedAt'] as String),
        deviceId: value['deviceId'] as String,
      );
    }

    return RemoteJobVisitModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: JobVisitStatus.values.byName(json['status'] as String),
      photoPath: json['photoPath'] as String?,
      fieldVersions: fieldVersions,
    );
  }

  factory RemoteJobVisitModel.fromEntity(
    jobvisitversionentity.JobVisitVersion entity,
  ) {
    return RemoteJobVisitModel(
      id: entity.visit.id,
      timestamp: entity.visit.timestamp,
      latitude: entity.visit.latitude,
      longitude: entity.visit.longitude,
      status: entity.visit.status,
      photoPath: entity.visit.photoPath,
      fieldVersions: entity.fieldVersions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'status': status.name,
      'photoPath': photoPath,
      'fieldVersions': {
        for (final entry in fieldVersions.entries)
          entry.key.name: {
            'updatedAt': entry.value.updatedAt.toIso8601String(),
            'deviceId': entry.value.deviceId,
          },
      },
    };
  }

  jobvisitversionentity.JobVisitVersion toVersionedEntity() {
    return jobvisitversionentity.JobVisitVersion(
      visit: jobvisitentity.JobVisit(
        id: id,
        timestamp: timestamp,
        latitude: latitude,
        longitude: longitude,
        status: status,
        photoPath: photoPath,
      ),
      fieldVersions: fieldVersions,
    );
  }
}
