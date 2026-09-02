import 'package:field_operations_app/features/sync/data/datasources/local/sync_local_data_source.dart';
import 'package:field_operations_app/features/sync/domain/entities/sync_operation.dart'
    as entity;
import 'package:field_operations_app/features/sync/domain/repositories/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  const SyncRepositoryImpl(this._localDataSource);

  final SyncLocalDataSource _localDataSource;

  @override
  Future<List<entity.SyncOperation>> getSyncableOperations() async {
    return await _localDataSource.getSyncableOperations();
  }

  @override
  Future<void> markInProgress(int operationId) async {
    return await _localDataSource.markInProgress(operationId);
  }

  @override
  Future<void> markCompleted(int operationId) async {
    return await _localDataSource.markCompleted(operationId);
  }

  @override
  Future<void> markFailed(int operationId) async {
    return await _localDataSource.markFailed(operationId);
  }
}
