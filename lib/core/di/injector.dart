import 'package:field_operations_app/core/utils/services/local_auth/local_auth_service.dart';
import 'package:field_operations_app/database/app_database.dart';
import 'package:field_operations_app/database/daos/job_visit/job_visit_dao.dart';
import 'package:field_operations_app/features/job_visits/data/datasources/local/job_visit_local_data_source_impl.dart';
import 'package:field_operations_app/features/job_visits/data/repositories/job_visit_repository_impl.dart';
import 'package:field_operations_app/features/job_visits/domain/usecases/create_job_visit.dart';
import 'package:field_operations_app/features/job_visits/domain/usecases/update_job_visit.dart';
import 'package:field_operations_app/features/job_visits/domain/usecases/watch_job_visits.dart';
import 'package:field_operations_app/features/job_visits/presentation/bloc/job_visit_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> inject(AppDatabase database) async {
  getIt.registerLazySingleton(() => LocalAuthServices());

  getIt.registerLazySingleton(() => JobVisitDao(database));

  getIt.registerLazySingleton(
    () => JobVisitLocalDataSourceImpl(dao: getIt<JobVisitDao>()),
  );

  getIt.registerLazySingleton(
    () => JobVisitRepositoryImpl(
      localDataSource: getIt<JobVisitLocalDataSourceImpl>(),
    ),
  );

  getIt.registerLazySingleton(
    () => WatchJobVisits(repository: getIt<JobVisitRepositoryImpl>()),
  );

  getIt.registerLazySingleton(
    () => CreateJobVisit(repository: getIt<JobVisitRepositoryImpl>()),
  );

  getIt.registerLazySingleton(
    () => UpdateJobVisit(repository: getIt<JobVisitRepositoryImpl>()),
  );

  getIt.registerLazySingleton(
    () => JobVisitBloc(
      watchJobVisits: getIt<WatchJobVisits>(),
      createJobVisit: getIt<CreateJobVisit>(),
      updateJobVisit: getIt<UpdateJobVisit>(),
    ),
  );
}
