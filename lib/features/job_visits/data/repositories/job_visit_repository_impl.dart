import 'package:field_operations_app/database/daos/job_visit/job_visit_dao.dart';
import 'package:field_operations_app/features/job_visits/data/datasources/local/job_visit_local_data_source.dart';
import 'package:field_operations_app/features/job_visits/data/models/job_visit_model.dart';
import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;
import 'package:field_operations_app/features/job_visits/domain/repositories/job_visit_repository.dart';

class JobVisitRepositoryImpl implements JobVisitRepository {
  const JobVisitRepositoryImpl({
    required this._dao,
    required this._localDataSource,
  });

  final JobVisitDao _dao;
  final JobVisitLocalDataSource _localDataSource;

  @override
  Future<entity.JobVisit> create(entity.JobVisit visit) async {
    final model = JobVisitModel.fromEntity(visit);

    // await _dao.insertVisit(model.toCompanion());
    await _localDataSource.create(model);

    return visit;
  }

  @override
  Future<entity.JobVisit> update(entity.JobVisit visit) async {
    // final model = JobVisitModel.fromEntity(visit);

    // await _dao.updateVisit(model.toCompanion());
    final existing = await _localDataSource.getById(visit.id);
    if (existing == null) {
      throw StateError(
        'Cannot update JobVisit ${visit.id}: visit does not exist.',
      );
    }
    final updatedModel = JobVisitModel.fromEntity(visit);
    final changedFields = _changedFields(existing, updatedModel);
    if (changedFields.isEmpty) {
      return visit;
    }
    await _localDataSource.update(updatedModel, changedFields);

    return visit;
  }

  @override
  Future<entity.JobVisit?> getById(String id) async {
    final data = await _dao.findById(id);

    return data == null ? null : JobVisitModel.fromDatabase(data).toEntity();
  }

  @override
  Stream<List<entity.JobVisit>> watchAll() {
    return _dao.watchAll().map(
      (items) => items
          .map((item) => JobVisitModel.fromDatabase(item).toEntity())
          .toList(),
    );
  }

  Set<String> _changedFields(JobVisitModel existing, JobVisitModel updated) {
    final fields = <String>{};
    if (existing.timestamp != updated.timestamp) {
      fields.add('timestamp');
    }
    if (existing.latitude != updated.latitude) {
      fields.add('latitude');
    }
    if (existing.longitude != updated.longitude) {
      fields.add('longitude');
    }
    if (existing.status != updated.status) {
      fields.add('status');
    }
    if (existing.photoPath != updated.photoPath) {
      fields.add('photoPath');
    }
    return fields;
  }
}
