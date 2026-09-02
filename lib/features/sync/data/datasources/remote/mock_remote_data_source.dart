import 'dart:convert';

import 'package:field_operations_app/features/sync/data/datasources/remote/sync_remote_data_source.dart';
import 'package:field_operations_app/features/sync/data/models/remote_job_visit_model.dart';
import 'package:flutter/services.dart';

class MockSyncRemoteDataSource implements SyncRemoteDataSource {
  MockSyncRemoteDataSource({
    this.assetPath = 'assets/mock/remote_job_visits.json',
  });

  final String assetPath;

  final Map<String, RemoteJobVisitModel> _visits = {};

  bool shouldFail = false;

  int? failOnCall;

  int successfulOperations = 0;

  int totalCalls = 0;

  bool _initialized = false;

  Map<String, RemoteJobVisitModel> get visits => Map.unmodifiable(_visits);

  Future<void> _initialize() async {
    if (_initialized) {
      return;
    }

    final jsonString = await rootBundle.loadString(assetPath);

    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    final rawVisits = json['jobVisits'] as List<dynamic>;

    for (final rawVisit in rawVisits) {
      final visit = RemoteJobVisitModel.fromJson(
        rawVisit as Map<String, dynamic>,
      );

      _visits[visit.id] = visit;
    }

    _initialized = true;
  }

  @override
  Future<RemoteJobVisitModel?> getJobVisit(String visitId) async {
    await _initialize();

    return _visits[visitId];
  }

  @override
  Future<void> upsertJobVisit(RemoteJobVisitModel visit) async {
    await _initialize();

    totalCalls++;

    if (shouldFail || (failOnCall != null && totalCalls == failOnCall)) {
      throw Exception('Mock sync failure');
    }

    _visits[visit.id] = visit;

    successfulOperations++;
  }

  @override
  Future<List<RemoteJobVisitModel>> getJobVisits() async {
    await _initialize();

    return _visits.values.toList();
  }
}
