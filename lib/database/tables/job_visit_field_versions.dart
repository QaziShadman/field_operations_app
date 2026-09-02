import 'package:drift/drift.dart';

class JobVisitFieldVersions extends Table {
  TextColumn get visitId => text()();

  TextColumn get fieldName => text()();

  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get deviceId => text()();

  @override
  Set<Column<Object>> get primaryKey => {visitId, fieldName};
}
