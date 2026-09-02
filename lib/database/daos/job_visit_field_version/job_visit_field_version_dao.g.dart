// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_visit_field_version_dao.dart';

// ignore_for_file: type=lint
mixin _$JobVisitFieldVersionDaoMixin on DatabaseAccessor<AppDatabase> {
  $JobVisitFieldVersionsTable get jobVisitFieldVersions =>
      attachedDatabase.jobVisitFieldVersions;
  JobVisitFieldVersionDaoManager get managers =>
      JobVisitFieldVersionDaoManager(this);
}

class JobVisitFieldVersionDaoManager {
  final _$JobVisitFieldVersionDaoMixin _db;
  JobVisitFieldVersionDaoManager(this._db);
  $$JobVisitFieldVersionsTableTableManager get jobVisitFieldVersions =>
      $$JobVisitFieldVersionsTableTableManager(
        _db.attachedDatabase,
        _db.jobVisitFieldVersions,
      );
}
