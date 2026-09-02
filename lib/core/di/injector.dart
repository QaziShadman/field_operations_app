import 'package:field_operations_app/core/utils/services/connectivity/connectivity_service.dart';
import 'package:field_operations_app/core/utils/services/debug/debug_database_service.dart';
import 'package:field_operations_app/core/utils/services/local_auth/local_auth_service.dart';
import 'package:field_operations_app/database/app_database.dart';
import 'package:field_operations_app/database/daos/job_visit/job_visit_dao.dart';
import 'package:field_operations_app/database/daos/job_visit_field_version/job_visit_field_version_dao.dart';
import 'package:field_operations_app/database/daos/sync/sync_operation_dao.dart';
import 'package:field_operations_app/features/job_visits/data/datasources/local/job_visit_local_data_source_impl.dart';
import 'package:field_operations_app/features/job_visits/data/repositories/job_visit_repository_impl.dart';
import 'package:field_operations_app/features/job_visits/domain/usecases/create_job_visit.dart';
import 'package:field_operations_app/features/job_visits/domain/usecases/update_job_visit.dart';
import 'package:field_operations_app/features/job_visits/domain/usecases/watch_job_visits.dart';
import 'package:field_operations_app/features/job_visits/presentation/bloc/job_visit_bloc.dart';
import 'package:field_operations_app/features/sync/data/datasources/local/job_visit_version_local_data_source_impl.dart';
import 'package:field_operations_app/features/sync/data/datasources/local/sync_local_data_source_impl.dart';
import 'package:field_operations_app/features/sync/data/datasources/remote/mock_remote_data_source.dart';
import 'package:field_operations_app/features/sync/data/repositories/job_visit_version_repository_impl.dart';
import 'package:field_operations_app/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:field_operations_app/features/sync/domain/services/job_visit_conflict_resolver.dart';
import 'package:field_operations_app/features/sync/domain/services/job_visit_merge_service.dart';
import 'package:field_operations_app/features/sync/domain/services/sync_coordinator.dart';
import 'package:field_operations_app/features/sync/domain/services/sync_engine.dart';
import 'package:field_operations_app/features/sync/domain/usecases/get_syncable_operations.dart';
import 'package:field_operations_app/features/sync/domain/usecases/mark_completed.dart';
import 'package:field_operations_app/features/sync/domain/usecases/mark_failed.dart';
import 'package:field_operations_app/features/sync/domain/usecases/mark_in_progress.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> inject(AppDatabase database) async {
  getIt.registerLazySingleton(() => LocalAuthServices());
  getIt.registerLazySingleton(() => ConnectivityServices());
  getIt.registerLazySingleton(() => DebugDatabaseService(database: database));

  getIt.registerLazySingleton(() => JobVisitDao(database));
  getIt.registerLazySingleton(() => SyncOperationDao(database));
  getIt.registerLazySingleton(() => JobVisitFieldVersionDao(database));

  // Job Visit
  getIt.registerLazySingleton(
    () => JobVisitLocalDataSourceImpl(
      database: database,
      dao: getIt<JobVisitDao>(),
    ),
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

  // Sync
  getIt.registerLazySingleton(
    () => SyncLocalDataSourceImpl(dao: getIt<SyncOperationDao>()),
  );

  getIt.registerLazySingleton(() => MockSyncRemoteDataSource());

  getIt.registerLazySingleton(
    () => JobVisitVersionLocalDataSourceImpl(
      database: database,
      jobVisitDao: getIt<JobVisitDao>(),
      fieldVersionDao: getIt<JobVisitFieldVersionDao>(),
    ),
  );

  getIt.registerLazySingleton(
    () => SyncRepositoryImpl(localDataSource: getIt<SyncLocalDataSourceImpl>()),
  );

  getIt.registerLazySingleton(
    () => JobVisitVersionRepositoryImpl(
      localDataSource: getIt<JobVisitVersionLocalDataSourceImpl>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetSyncableOperations(repository: getIt<SyncRepositoryImpl>()),
  );

  getIt.registerLazySingleton(
    () => MarkCompleted(repository: getIt<SyncRepositoryImpl>()),
  );

  getIt.registerLazySingleton(
    () => MarkFailed(repository: getIt<SyncRepositoryImpl>()),
  );

  getIt.registerLazySingleton(
    () => MarkInProgress(repository: getIt<SyncRepositoryImpl>()),
  );

  getIt.registerLazySingleton(() => JobVisitConflictResolver());

  getIt.registerLazySingleton(
    () => JobVisitMergeService(
      conflictResolver: getIt<JobVisitConflictResolver>(),
    ),
  );

  getIt.registerLazySingleton(
    () => SyncEngine(
      syncRepository: getIt<SyncRepositoryImpl>(),
      jobVisitVersionRepository: getIt<JobVisitVersionRepositoryImpl>(),
      remoteDataSource: getIt<MockSyncRemoteDataSource>(),
      mergeService: getIt<JobVisitMergeService>(),
    ),
  );

  getIt.registerLazySingleton(
    () => SyncCoordinator(
      connectivity: getIt<ConnectivityServices>(),
      syncEngine: getIt<SyncEngine>(),
    ),
  );
}
