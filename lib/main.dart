import 'package:field_operations_app/core/app/app.dart';
import 'package:field_operations_app/core/di/injector.dart';
import 'package:material_ui/material_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await inject();

  runApp(const FieldOperationsApp());
}
