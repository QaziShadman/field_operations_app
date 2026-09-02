import 'package:drift/drift.dart';
import 'package:field_operations_app/database/app_database.dart';
import 'package:field_operations_app/database/tables/job_visit_field_versions.dart';

part 'job_visit_field_version_dao.g.dart';

@DriftAccessor(tables: [JobVisitFieldVersions])
class JobVisitFieldVersionDao extends DatabaseAccessor<AppDatabase>
    with _$JobVisitFieldVersionDaoMixin {
  JobVisitFieldVersionDao(super.db);

  Future<List<JobVisitFieldVersion>> getByVisitId(String visitId) {
    return (select(
      jobVisitFieldVersions,
    )..where((table) => table.visitId.equals(visitId))).get();
  }

  Future<void> deleteByVisitId(String visitId) {
    return (delete(
      jobVisitFieldVersions,
    )..where((table) => table.visitId.equals(visitId))).go();
  }

  Future<void> insert(JobVisitFieldVersionsCompanion version) {
    return into(jobVisitFieldVersions).insert(version);
  }
}
