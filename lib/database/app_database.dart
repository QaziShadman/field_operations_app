import 'package:drift/drift.dart';
import 'package:field_operations_app/database/daos/job_visit/job_visit_dao.dart';
import 'package:field_operations_app/database/daos/job_visit_field_version/job_visit_field_version_dao.dart';
import 'package:field_operations_app/database/daos/sync/sync_operation_dao.dart';
import 'package:field_operations_app/database/tables/job_visit_field_versions.dart';
import 'package:field_operations_app/database/tables/job_visits.dart';
import 'package:field_operations_app/database/tables/sync_operations.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [JobVisits, SyncOperations, JobVisitFieldVersions],
  daos: [JobVisitDao, SyncOperationDao, JobVisitFieldVersionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
