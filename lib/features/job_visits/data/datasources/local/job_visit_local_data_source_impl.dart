import 'package:field_operations_app/database/daos/job_visit/job_visit_dao.dart';
import 'package:field_operations_app/features/job_visits/data/datasources/local/job_visit_local_data_source.dart';
import 'package:field_operations_app/features/job_visits/data/models/job_visit_model.dart';

class JobVisitLocalDataSourceImpl implements JobVisitLocalDataSource {
  const JobVisitLocalDataSourceImpl({required this._dao});
  final JobVisitDao _dao;
  @override
  Future<void> create(JobVisitModel visit) async {
    return await _dao.insertVisit(visit.toCompanion());
  }

  @override
  Future<void> update(JobVisitModel visit, Set<String> changedFields) async {
    return await _dao.updateVisit(visit.toCompanion());
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
}
