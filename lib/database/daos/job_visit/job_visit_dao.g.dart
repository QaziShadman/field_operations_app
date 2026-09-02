// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_visit_dao.dart';

// ignore_for_file: type=lint
mixin _$JobVisitDaoMixin on DatabaseAccessor<AppDatabase> {
  $JobVisitsTable get jobVisits => attachedDatabase.jobVisits;
  $SyncOperationsTable get syncOperations => attachedDatabase.syncOperations;
  JobVisitDaoManager get managers => JobVisitDaoManager(this);
}

class JobVisitDaoManager {
  final _$JobVisitDaoMixin _db;
  JobVisitDaoManager(this._db);
  $$JobVisitsTableTableManager get jobVisits =>
      $$JobVisitsTableTableManager(_db.attachedDatabase, _db.jobVisits);
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(
        _db.attachedDatabase,
        _db.syncOperations,
      );
}
