import 'package:field_operations_app/features/sync/data/models/remote_job_visit_model.dart';

abstract interface class SyncRemoteDataSource {
  Future<void> upsertJobVisit(RemoteJobVisitModel visit);

  Future<RemoteJobVisitModel?> getJobVisit(String visitId);

  Future<List<RemoteJobVisitModel>> getJobVisits();
}
