import 'package:drift/drift.dart';
import 'package:field_operations_app/database/app_database.dart';
import 'package:field_operations_app/database/tables/job_visits.dart';
import 'package:field_operations_app/database/tables/sync_operations.dart';
import 'package:field_operations_app/features/job_visits/data/models/job_visit_with_sync_status_model.dart';
import 'package:material_ui/material_ui.dart';

part 'job_visit_dao.g.dart';

@DriftAccessor(tables: [JobVisits, SyncOperations])
class JobVisitDao extends DatabaseAccessor<AppDatabase>
    with _$JobVisitDaoMixin {
  JobVisitDao(super.db);

  Stream<List<JobVisit>> watchAll() {
    return select(jobVisits).watch();
  }

  Future<JobVisit?> findById(String id) {
    return (select(
      jobVisits,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertVisit(JobVisitsCompanion visit) {
    return transaction(() async {
      await into(jobVisits).insert(visit);
    });
  }

  Future<void> updateVisit(JobVisitsCompanion visit) {
    if (visit.id.present) {
      return transaction(() async {
        await (update(
          jobVisits,
        )..where((table) => table.id.equals(visit.id.value))).write(visit);
      });
    }

    throw ArgumentError('Job visit ID is required for update.');
  }

  Future<void> updateOrInsert(JobVisitsCompanion visit) {
    return into(jobVisits).insertOnConflictUpdate(visit);
  }

  Stream<List<JobVisitWithSyncStatusModel>> watchAllWithSyncStatus() {
    final query = select(jobVisits).join([
      leftOuterJoin(
        syncOperations,
        syncOperations.visitId.equalsExp(jobVisits.id),
      ),
    ]);

    return query.watch().map((rows) {
      debugPrint('JOB VISIT DAO: stream emitted ${rows.length} rows');
      return rows.map((row) {
        final jobVisit = row.readTable(jobVisits);
        final syncOperation = row.readTableOrNull(syncOperations);

        debugPrint(
          'JOB VISIT DAO: '
          'visit=${jobVisit.id}, '
          'sync=${syncOperation?.state}',
        );

        return JobVisitWithSyncStatusModel.fromDatabase(
          jobVisit: jobVisit,
          syncOperation: syncOperation,
        );
      }).toList();
    });
  }
}
