import 'package:field_operations_app/features/sync/data/datasources/local/job_visit_version_local_data_source.dart';
import 'package:field_operations_app/features/sync/domain/entities/job_visit_version.dart'
    as entity;
import 'package:field_operations_app/features/sync/domain/repositories/job_visit_version_repository.dart';

class JobVisitVersionRepositoryImpl implements JobVisitVersionRepository {
  const JobVisitVersionRepositoryImpl({required this._localDataSource});

  final JobVisitVersionLocalDataSource _localDataSource;

  @override
  Future<entity.JobVisitVersion?> getById(String visitId) {
    return _localDataSource.getById(visitId);
  }

  @override
  Future<void> save(entity.JobVisitVersion visit) {
    return _localDataSource.save(visit);
  }
}
