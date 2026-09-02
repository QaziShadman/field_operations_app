import 'package:field_operations_app/features/sync/domain/entities/sync_operation.dart'
    as entity;
import 'package:field_operations_app/features/sync/domain/repositories/sync_repository.dart';

class GetSyncableOperations {
  const GetSyncableOperations({required this._repository});

  final SyncRepository _repository;

  Future<List<entity.SyncOperation>> call() async {
    return await _repository.getSyncableOperations();
  }
}
