import 'package:field_operations_app/features/sync/domain/repositories/sync_repository.dart';

class MarkFailed {
  const MarkFailed({required this._repository});

  final SyncRepository _repository;

  Future<void> call(int operationId) async {
    return await _repository.markFailed(operationId);
  }
}
