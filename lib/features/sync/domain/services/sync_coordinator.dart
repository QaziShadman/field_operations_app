import 'dart:async';

import 'package:field_operations_app/core/utils/services/connectivity/connectivity_service.dart';
import 'package:field_operations_app/features/sync/domain/services/sync_engine.dart';
import 'package:material_ui/material_ui.dart';

class SyncCoordinator {
  SyncCoordinator({required this._connectivity, required this._syncEngine});

  final ConnectivityServices _connectivity;
  final SyncEngine _syncEngine;

  StreamSubscription<bool>? _subscription;

  bool _isSyncing = false;

  Future<void> start() async {
    debugPrint('SYNC COORDINATOR: start()');

    await _connectivity.startMonitoring();

    debugPrint('SYNC COORDINATOR: connected = ${_connectivity.isConnected}');

    _subscription ??= _connectivity.connectionStream.listen((isConnected) {
      debugPrint('SYNC COORDINATOR: connectivity changed = $isConnected');

      if (isConnected) {
        _sync();
      }
    });

    if (_connectivity.isConnected) {
      debugPrint('SYNC COORDINATOR: initial sync');
      await _sync();
    }
  }

  Future<void> _sync() async {
    debugPrint('SYNC COORDINATOR: _sync() called');

    if (_isSyncing) {
      debugPrint('SYNC COORDINATOR: already syncing');
      return;
    }

    _isSyncing = true;

    try {
      debugPrint('SYNC COORDINATOR: calling SyncEngine');

      await _syncEngine.sync();

      debugPrint('SYNC COORDINATOR: SyncEngine finished');
    } catch (error, stackTrace) {
      debugPrint('SYNC COORDINATOR: sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
