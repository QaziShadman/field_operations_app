import 'package:drift/drift.dart';
import 'package:field_operations_app/database/app_database.dart';
import 'package:field_operations_app/database/tables/sync_operations.dart';
import 'package:field_operations_app/features/sync/domain/enums/sync_operation_state.dart';

part 'sync_operation_dao.g.dart';

@DriftAccessor(tables: [SyncOperations])
class SyncOperationDao extends DatabaseAccessor<AppDatabase>
    with _$SyncOperationDaoMixin {
  SyncOperationDao(super.db);

  Future<List<SyncOperation>> getSyncableOperations() {
    return (select(syncOperations)
          ..where(
            (table) => table.state.isIn([
              SyncOperationState.pending.name,
              SyncOperationState.failed.name,
            ]),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
  }

  Future<SyncOperation?> findById(int id) {
    return (select(
      syncOperations,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<void> markInProgress(int operationId) {
    return _updateState(operationId, SyncOperationState.inProgress);
  }

  Future<void> markCompleted(int operationId) {
    return _updateState(operationId, SyncOperationState.completed);
  }

  Future<void> markFailed(int operationId) {
    return transaction(() async {
      final operation = await (select(
        syncOperations,
      )..where((table) => table.id.equals(operationId))).getSingle();

      await (update(
        syncOperations,
      )..where((table) => table.id.equals(operationId))).write(
        SyncOperationsCompanion(
          state: Value(SyncOperationState.failed.name),
          attemptCount: Value(operation.attemptCount + 1),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> _updateState(int operationId, SyncOperationState state) {
    return (update(
      syncOperations,
    )..where((table) => table.id.equals(operationId))).write(
      SyncOperationsCompanion(
        state: Value(state.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
