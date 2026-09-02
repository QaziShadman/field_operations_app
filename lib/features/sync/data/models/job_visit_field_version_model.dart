import 'package:field_operations_app/database/app_database.dart' as db;
import 'package:field_operations_app/features/sync/domain/entities/job_visit_version.dart'
    as entity;
import 'package:field_operations_app/features/sync/domain/enums/job_visit_sync_field.dart';

class JobVisitFieldVersionModel {
  const JobVisitFieldVersionModel({required this.field, required this.version});

  final JobVisitSyncField field;
  final entity.FieldVersion version;

  factory JobVisitFieldVersionModel.fromDatabase(db.JobVisitFieldVersion row) {
    return JobVisitFieldVersionModel(
      field: JobVisitSyncField.values.byName(row.fieldName),
      version: entity.FieldVersion(
        updatedAt: row.updatedAt,
        deviceId: row.deviceId,
      ),
    );
  }

  factory JobVisitFieldVersionModel.fromEntity(
    JobVisitSyncField field,
    entity.FieldVersion version,
  ) {
    return JobVisitFieldVersionModel(field: field, version: version);
  }

  db.JobVisitFieldVersionsCompanion toCompanion(String visitId) {
    return db.JobVisitFieldVersionsCompanion.insert(
      visitId: visitId,
      fieldName: field.name,
      updatedAt: version.updatedAt,
      deviceId: version.deviceId,
    );
  }
}
