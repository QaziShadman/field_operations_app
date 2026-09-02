import 'package:drift/drift.dart';
import 'package:field_operations_app/database/app_database.dart';
import 'package:field_operations_app/database/daos/job_visit/job_visit_dao.dart';
import 'package:field_operations_app/features/job_visits/data/datasources/local/job_visit_local_data_source.dart';
import 'package:field_operations_app/features/job_visits/data/models/job_visit_model.dart';
import 'package:field_operations_app/features/job_visits/data/models/job_visit_with_sync_status_model.dart';

class JobVisitLocalDataSourceImpl implements JobVisitLocalDataSource {
  const JobVisitLocalDataSourceImpl({
    required this._database,
    required this._dao,
  });
  final AppDatabase _database;
  final JobVisitDao _dao;
  @override
  Future<void> create(JobVisitModel visit) async {
    final now = DateTime.now();
    return await _database.transaction(() async {
      await _dao.insertVisit(visit.toCompanion());
      await _insertFieldVersions(
        visitId: visit.id,
        fields: _fieldsForVisit(visit),
        updatedAt: now,
      );
      await _insertSyncOperation(visitId: visit.id, createdAt: now);
    });
  }

  @override
  Future<void> update(JobVisitModel visit, Set<String> changedFields) async {
    final now = DateTime.now();
    return await _database.transaction(() async {
      final companion = visit.toCompanion();

      final updateCompanion = companion.copyWith(
        photoPath: changedFields.contains('photoPath')
            ? Value(visit.photoPath)
            : companion.photoPath,
      );

      await _dao.updateVisit(updateCompanion);

      await _insertFieldVersions(
        visitId: visit.id,
        fields: changedFields,
        updatedAt: now,
      );

      await _insertSyncOperation(visitId: visit.id, createdAt: now);
    });
  }

  @override
  Future<JobVisitModel?> getById(String id) async {
    final row = await _dao.findById(id);
    if (row == null) {
      return null;
    }
    return JobVisitModel.fromDatabase(row);
  }

  @override
  Stream<List<JobVisitModel>> watchAll() {
    return _dao.watchAll().map(
      (rows) => rows.map(JobVisitModel.fromDatabase).toList(),
    );
  }

  @override
  Stream<List<JobVisitWithSyncStatusModel>> watchAllWithSyncStatus() {
    return _dao.watchAllWithSyncStatus();
  }

  Future<void> _insertFieldVersions({
    required String visitId,
    required Set<String> fields,
    required DateTime updatedAt,
  }) async {
    for (final field in fields) {
      await _database
          .into(_database.jobVisitFieldVersions)
          .insertOnConflictUpdate(
            JobVisitFieldVersionsCompanion.insert(
              visitId: visitId,
              fieldName: field,
              updatedAt: updatedAt,
              deviceId: 'local',
            ),
          );
    }
  }

  Future<void> _insertSyncOperation({
    required String visitId,
    required DateTime createdAt,
  }) {
    return _database
        .into(_database.syncOperations)
        .insert(
          SyncOperationsCompanion.insert(
            visitId: visitId,
            operationType: 'upsert',
            state: 'pending',
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        );
  }

  Set<String> _fieldsForVisit(JobVisitModel visit) {
    final fields = <String>{'timestamp', 'latitude', 'longitude', 'status'};
    if (visit.photoPath != null) {
      fields.add('photoPath');
    }
    return fields;
  }
}
