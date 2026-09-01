import 'package:field_operations_app/core/app/app.dart';
import 'package:field_operations_app/core/di/injector.dart';
import 'package:field_operations_app/database/app_database.dart';
import 'package:field_operations_app/database/db_connection.dart';
import 'package:material_ui/material_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppDatabase database = createAppDatabase();

  await inject(database);

  runApp(FieldOperationsApp(database: database));
}
