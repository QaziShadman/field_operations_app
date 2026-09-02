import 'package:field_operations_app/features/sync/data/datasources/remote/sync_remote_data_source.dart';
import 'package:field_operations_app/features/sync/data/models/remote_job_visit_model.dart';
import 'package:field_operations_app/features/sync/domain/entities/sync_operation.dart'
    as entity;
import 'package:field_operations_app/features/sync/domain/enums/sync_operation_type.dart';
import 'package:field_operations_app/features/sync/domain/repositories/job_visit_version_repository.dart';
import 'package:field_operations_app/features/sync/domain/repositories/sync_repository.dart';
import 'package:field_operations_app/features/sync/domain/services/job_visit_merge_service.dart';
import 'package:material_ui/material_ui.dart';

class SyncEngine {
  const SyncEngine({
    required this._syncRepository,
    required this._jobVisitVersionRepository,
    required this._remoteDataSource,
    required this._mergeService,
  });

  final SyncRepository _syncRepository;
  final JobVisitVersionRepository _jobVisitVersionRepository;
  final SyncRemoteDataSource _remoteDataSource;
  final JobVisitMergeService _mergeService;

  Future<void> sync() async {
    debugPrint('SYNC ENGINE: sync()');
    // 1. Push local changes.
    final operations = await _syncRepository.getSyncableOperations();

    debugPrint('SYNC ENGINE: ${operations.length} operations');

    for (final operation in operations) {
      await _processOperation(operation);
    }

    // 2. Pull remote changes.
    await _pullRemoteVisits();
  }

  Future<void> _processOperation(entity.SyncOperation operation) async {
    await _syncRepository.markInProgress(operation.id);

    try {
      switch (operation.operationType) {
        case SyncOperationType.upsert:
          await _syncVisit(operation);
          break;
      }

      await _syncRepository.markCompleted(operation.id);
    } catch (_) {
      await _syncRepository.markFailed(operation.id);
      rethrow;
    }
  }

  Future<void> _pullRemoteVisits() async {
    final remoteVisits = await _remoteDataSource.getJobVisits();

    for (final remoteVisit in remoteVisits) {
      final localVisit = await _jobVisitVersionRepository.getById(
        remoteVisit.id,
      );

      if (localVisit == null) {
        // Doesn't exist locally yet.
        await _jobVisitVersionRepository.save(remoteVisit.toVersionedEntity());

        continue;
      }

      final mergedVisit = _mergeService.merge(
        local: localVisit,
        remote: remoteVisit.toVersionedEntity(),
      );

      await _jobVisitVersionRepository.save(mergedVisit);
    }
  }

  Future<void> _syncVisit(entity.SyncOperation operation) async {
    final localVisit = await _jobVisitVersionRepository.getById(
      operation.visitId,
    );

    if (localVisit == null) {
      throw StateError(
        'Job Visit ${operation.visitId} no longer exists locally.',
      );
    }

    final remoteVisit = await _remoteDataSource.getJobVisit(operation.visitId);

    if (remoteVisit == null) {
      // The Job Visit does not exist remotely yet.
      // There is nothing to merge, so upload the local version.
      await _remoteDataSource.upsertJobVisit(
        RemoteJobVisitModel.fromEntity(localVisit),
      );

      return;
    }

    // Both local and remote versions exist.
    // Resolve conflicts independently for each field.
    final mergedVisit = _mergeService.merge(
      local: localVisit,
      remote: remoteVisit.toVersionedEntity(),
    );

    // Persist the merged result locally.
    await _jobVisitVersionRepository.save(mergedVisit);

    // Upload the merged result to the mock backend.
    await _remoteDataSource.upsertJobVisit(
      RemoteJobVisitModel.fromEntity(mergedVisit),
    );
  }
}
