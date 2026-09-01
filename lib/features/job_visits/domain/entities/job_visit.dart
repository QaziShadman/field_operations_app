import 'package:field_operations_app/features/job_visits/domain/enums/job_visit_status.dart';

class JobVisit {
  const JobVisit({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.photoPath,
  });

  final String id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final JobVisitStatus status;
  final String? photoPath;
}
