import 'package:drift/drift.dart';

class JobVisits extends Table {
  TextColumn get id => text()();

  DateTimeColumn get timestamp => dateTime()();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();

  TextColumn get status => text()();

  TextColumn get photoPath => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
