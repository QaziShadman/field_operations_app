import 'package:drift/drift.dart';
import 'package:field_operations_app/database/daos/job_visit/job_visit_dao.dart';
import 'package:field_operations_app/database/tables/job_visits.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [JobVisits], daos: [JobVisitDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
