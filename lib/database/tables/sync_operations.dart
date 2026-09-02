import 'package:drift/drift.dart';

class SyncOperations extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get visitId => text()();

  TextColumn get operationType => text()();

  TextColumn get state => text()();

  IntColumn get attemptCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
