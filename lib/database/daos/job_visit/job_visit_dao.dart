import 'package:drift/drift.dart';
import 'package:field_operations_app/database/app_database.dart';
import 'package:field_operations_app/database/tables/job_visits.dart';

part 'job_visit_dao.g.dart';

@DriftAccessor(tables: [JobVisits])
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
    return into(jobVisits).insert(visit);
  }

  Future<void> updateVisit(JobVisitsCompanion visit) {
    if (visit.id.present) {
      return (update(
        jobVisits,
      )..where((table) => table.id.equals(visit.id.value))).write(visit);
    }

    throw ArgumentError('Job visit ID is required for update.');
  }
}
