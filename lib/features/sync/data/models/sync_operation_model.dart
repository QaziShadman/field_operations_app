import 'package:field_operations_app/database/app_database.dart' as db;
import 'package:field_operations_app/features/sync/domain/entities/sync_operation.dart'
    as entity;
import 'package:field_operations_app/features/sync/domain/enums/sync_operation_state.dart';
import 'package:field_operations_app/features/sync/domain/enums/sync_operation_type.dart';

class SyncOperationModel {
  const SyncOperationModel({
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

  factory SyncOperationModel.fromEntity(entity.SyncOperation entity) {
    return SyncOperationModel(
      id: entity.id,
      visitId: entity.visitId,
      operationType: entity.operationType,
      state: entity.state,
      attemptCount: entity.attemptCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory SyncOperationModel.fromDatabase(db.SyncOperation row) {
    return SyncOperationModel(
      id: row.id,
      visitId: row.visitId,
      operationType: SyncOperationType.values.byName(row.operationType),
      state: SyncOperationState.values.byName(row.state),
      attemptCount: row.attemptCount,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  entity.SyncOperation toEntity() {
    return entity.SyncOperation(
      id: id,
      visitId: visitId,
      operationType: operationType,
      state: state,
      attemptCount: attemptCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
