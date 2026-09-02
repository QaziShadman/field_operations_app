import 'package:field_operations_app/features/sync/domain/entities/sync_operation.dart'
    as entity;

abstract interface class SyncRepository {
  Future<List<entity.SyncOperation>> getSyncableOperations();

  Future<void> markInProgress(int operationId);

  Future<void> markCompleted(int operationId);

  Future<void> markFailed(int operationId);
}
