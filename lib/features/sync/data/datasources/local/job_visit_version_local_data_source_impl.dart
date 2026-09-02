import 'package:field_operations_app/database/app_database.dart';
import 'package:field_operations_app/database/daos/job_visit/job_visit_dao.dart';
import 'package:field_operations_app/database/daos/job_visit_field_version/job_visit_field_version_dao.dart';
import 'package:field_operations_app/features/job_visits/data/models/job_visit_model.dart';
import 'package:field_operations_app/features/sync/data/datasources/local/job_visit_version_local_data_source.dart';
import 'package:field_operations_app/features/sync/data/models/job_visit_field_version_model.dart';
import 'package:field_operations_app/features/sync/domain/entities/job_visit_version.dart'
    as entity;
import 'package:field_operations_app/features/sync/domain/enums/job_visit_sync_field.dart';

class JobVisitVersionLocalDataSourceImpl
    implements JobVisitVersionLocalDataSource {
  const JobVisitVersionLocalDataSourceImpl({
    required this._database,
    required this._jobVisitDao,
    required this._fieldVersionDao,
  });

  final AppDatabase _database;
  final JobVisitDao _jobVisitDao;
  final JobVisitFieldVersionDao _fieldVersionDao;

  @override
  Future<entity.JobVisitVersion?> getById(String visitId) async {
    final visit = await _jobVisitDao.findById(visitId);

    if (visit == null) {
      return null;
    }

    final versions = await _fieldVersionDao.getByVisitId(visitId);

    final fieldVersions = <JobVisitSyncField, entity.FieldVersion>{};

    for (final row in versions) {
      final model = JobVisitFieldVersionModel.fromDatabase(row);

      fieldVersions[model.field] = model.version;
    }

    return entity.JobVisitVersion(
      visit: JobVisitModel.fromDatabase(visit).toEntity(),
      fieldVersions: fieldVersions,
    );
  }

  @override
  Future<void> save(entity.JobVisitVersion versionedVisit) {
    return _database.transaction(() async {
      await _jobVisitDao.updateOrInsert(
        JobVisitModel.fromEntity(versionedVisit.visit).toCompanion(),
      );

      await _fieldVersionDao.deleteByVisitId(versionedVisit.visit.id);

      for (final entry in versionedVisit.fieldVersions.entries) {
        final model = JobVisitFieldVersionModel.fromEntity(
          entry.key,
          entry.value,
        );

        await _fieldVersionDao.insert(
          model.toCompanion(versionedVisit.visit.id),
        );
      }
    });
  }
}
