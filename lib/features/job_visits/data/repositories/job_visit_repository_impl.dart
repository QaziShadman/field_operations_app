import 'package:field_operations_app/database/daos/job_visit/job_visit_dao.dart';
import 'package:field_operations_app/features/job_visits/data/models/job_visit_model.dart';
import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;
import 'package:field_operations_app/features/job_visits/domain/repositories/job_visit_repository.dart';

class JobVisitRepositoryImpl implements JobVisitRepository {
  const JobVisitRepositoryImpl(this._dao);

  final JobVisitDao _dao;

  @override
  Future<entity.JobVisit> create(entity.JobVisit visit) async {
    final model = JobVisitModel.fromEntity(visit);

    await _dao.insertVisit(model.toCompanion());

    return visit;
  }

  @override
  Future<entity.JobVisit> update(entity.JobVisit visit) async {
    final model = JobVisitModel.fromEntity(visit);

    await _dao.updateVisit(model.toCompanion());

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
}
