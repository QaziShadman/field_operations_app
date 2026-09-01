import 'package:drift/drift.dart';
import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;
import 'package:field_operations_app/database/app_database.dart' as db;
import 'package:field_operations_app/features/job_visits/domain/enums/job_visit_status.dart';

class JobVisitModel {
  const JobVisitModel({
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

  factory JobVisitModel.fromEntity(entity.JobVisit entity) {
    return JobVisitModel(
      id: entity.id,
      timestamp: entity.timestamp,
      latitude: entity.latitude,
      longitude: entity.longitude,
      status: entity.status,
      photoPath: entity.photoPath,
    );
  }

  entity.JobVisit toEntity() {
    return entity.JobVisit(
      id: id,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      status: status,
      photoPath: photoPath,
    );
  }

  factory JobVisitModel.fromDatabase(db.JobVisit data) {
    return JobVisitModel(
      id: data.id,
      timestamp: data.timestamp,
      latitude: data.latitude,
      longitude: data.longitude,
      status: _statusFromDatabase(data.status),
      photoPath: data.photoPath,
    );
  }

  static JobVisitStatus _statusFromDatabase(String value) {
    switch (value) {
      case 'en_route':
        return JobVisitStatus.enRoute;
      case 'on_site':
        return JobVisitStatus.onSite;
      case 'completed':
        return JobVisitStatus.completed;
      case 'blocked':
        return JobVisitStatus.blocked;
      default:
        throw ArgumentError('Unknown job visit status: $value');
    }
  }

  db.JobVisitsCompanion toCompanion() {
    return db.JobVisitsCompanion.insert(
      id: id,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      status: _statusToDatabase(status),
      photoPath: Value(photoPath),
    );
  }

  static String _statusToDatabase(JobVisitStatus status) {
    switch (status) {
      case JobVisitStatus.enRoute:
        return 'en_route';
      case JobVisitStatus.onSite:
        return 'on_site';
      case JobVisitStatus.completed:
        return 'completed';
      case JobVisitStatus.blocked:
        return 'blocked';
    }
  }
}
