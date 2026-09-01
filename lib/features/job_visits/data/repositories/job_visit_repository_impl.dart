import 'package:field_operations_app/features/job_visits/data/datasources/local/job_visit_local_data_source.dart';
import 'package:field_operations_app/features/job_visits/data/models/job_visit_model.dart';
import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;
import 'package:field_operations_app/features/job_visits/domain/repositories/job_visit_repository.dart';

class JobVisitRepositoryImpl implements JobVisitRepository {
  const JobVisitRepositoryImpl({required this._localDataSource});

  final JobVisitLocalDataSource _localDataSource;

  @override
  Future<entity.JobVisit> create(entity.JobVisit visit) async {
    final model = JobVisitModel.fromEntity(visit);

    await _localDataSource.create(model);

    return visit;
  }

  @override
  Future<entity.JobVisit> update(entity.JobVisit visit) async {
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
    final data = await _localDataSource.getById(id);

    return data?.toEntity();
  }

  @override
  Stream<List<entity.JobVisit>> watchAll() {
    return _localDataSource.watchAll().map(
      (items) => items.map((item) => item.toEntity()).toList(),
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
