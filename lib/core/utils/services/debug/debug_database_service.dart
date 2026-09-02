import 'package:field_operations_app/database/app_database.dart';

class DebugDatabaseService {
  const DebugDatabaseService({required this._database});

  final AppDatabase _database;

  Future<void> resetSyncData() async {
    await _database.transaction(() async {
      await _database.delete(_database.syncOperations).go();
      await _database.delete(_database.jobVisitFieldVersions).go();
      await _database.delete(_database.jobVisits).go();
    });
  }
}
