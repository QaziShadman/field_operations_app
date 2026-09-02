import 'dart:async';

import 'package:field_operations_app/core/app/app.dart';
import 'package:field_operations_app/core/di/injector.dart';
import 'package:field_operations_app/database/app_database.dart';
import 'package:field_operations_app/database/db_connection.dart';
import 'package:field_operations_app/features/sync/domain/services/sync_coordinator.dart';
import 'package:material_ui/material_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppDatabase database = createAppDatabase();

  await inject(database);

  runApp(FieldOperationsApp(database: database));

  // Start sync monitoring without blocking UI startup.
  unawaited(getIt<SyncCoordinator>().start());
}
