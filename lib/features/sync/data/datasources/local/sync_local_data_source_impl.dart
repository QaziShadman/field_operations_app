import 'package:field_operations_app/database/daos/sync/sync_operation_dao.dart';
import 'package:field_operations_app/features/sync/data/datasources/local/sync_local_data_source.dart';
import 'package:field_operations_app/features/sync/data/models/sync_operation_model.dart';
import 'package:field_operations_app/features/sync/domain/entities/sync_operation.dart'
    as entity;

class SyncLocalDataSourceImpl implements SyncLocalDataSource {
  const SyncLocalDataSourceImpl({required this._dao});

  final SyncOperationDao _dao;

  @override
  Future<List<entity.SyncOperation>> getSyncableOperations() async {
    final rows = await _dao.getSyncableOperations();

    return rows
        .map((row) => SyncOperationModel.fromDatabase(row).toEntity())
        .toList();
  }

  @override
  Future<void> markInProgress(int operationId) async {
    return await _dao.markInProgress(operationId);
  }

  @override
  Future<void> markCompleted(int operationId) async {
    return await _dao.markCompleted(operationId);
  }

  @override
  Future<void> markFailed(int operationId) async {
    return await _dao.markFailed(operationId);
  }
}
