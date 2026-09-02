import 'package:field_operations_app/features/sync/domain/enums/sync_operation_state.dart';
import 'package:field_operations_app/features/sync/domain/enums/sync_operation_type.dart';

class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.visitId,
    required this.operationType,
    required this.state,
    required this.attemptCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String visitId;
  final SyncOperationType operationType;
  final SyncOperationState state;
  final int attemptCount;
  final DateTime createdAt;
  final DateTime updatedAt;
}
