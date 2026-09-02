import 'package:field_operations_app/features/sync/domain/entities/job_visit_version.dart'
    as entity;
import 'package:field_operations_app/features/sync/domain/services/job_visit_conflict_resolver.dart';

class JobVisitMergeService {
  const JobVisitMergeService({required this._conflictResolver});

  final JobVisitConflictResolver _conflictResolver;

  entity.JobVisitVersion merge({
    required entity.JobVisitVersion local,
    required entity.JobVisitVersion remote,
  }) {
    return _conflictResolver.merge(local, remote);
  }
}
