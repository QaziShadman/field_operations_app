import 'package:field_operations_app/core/app/app_theme.dart';
import 'package:field_operations_app/features/job_visits/presentation/pages/job_visit_list_page.dart';
import 'package:material_ui/material_ui.dart';

class FieldOperationsApp extends StatelessWidget {
  const FieldOperationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Operations',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const JobVisitListPage(),
    );
  }
}
