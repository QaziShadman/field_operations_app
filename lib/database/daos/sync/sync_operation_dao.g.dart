// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_operation_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncOperationDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncOperationsTable get syncOperations => attachedDatabase.syncOperations;
  SyncOperationDaoManager get managers => SyncOperationDaoManager(this);
}

class SyncOperationDaoManager {
  final _$SyncOperationDaoMixin _db;
  SyncOperationDaoManager(this._db);
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(
        _db.attachedDatabase,
        _db.syncOperations,
      );
}
