import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.dart';

AppDatabase createAppDatabase() {
  return AppDatabase(driftDatabase(name: 'field_operations'));
}
