import 'package:field_operations_app/core/app/app_theme.dart';
import 'package:field_operations_app/core/di/injector.dart';
import 'package:field_operations_app/database/app_database.dart';
import 'package:field_operations_app/features/job_visits/presentation/bloc/job_visit_bloc.dart';
import 'package:field_operations_app/features/job_visits/presentation/pages/job_visit_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

class FieldOperationsApp extends StatelessWidget {
  const FieldOperationsApp({required this.database, super.key});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Operations',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: BlocProvider(
        create: (_) => getIt<JobVisitBloc>()..add(const JobVisitStarted()),
        child: const JobVisitListPage(),
      ),
    );
  }
}
