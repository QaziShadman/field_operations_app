import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityServices {
  ConnectivityServices({
    Connectivity? connectivity,
    http.Client? httpClient,
    this.checkUrl = 'https://www.google.com',
  }) : _connectivity = connectivity ?? Connectivity(),
       _httpClient = httpClient ?? http.Client();

  final Connectivity _connectivity;
  final http.Client _httpClient;

  final String checkUrl;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _connectionController = StreamController<bool>.broadcast();

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Stream<bool> get connectionStream => _connectionController.stream;

  Future<void> startMonitoring() async {
    // Check the actual internet connection initially.
    await checkConnection();

    // Monitor network changes.
    _subscription ??= _connectivity.onConnectivityChanged.listen((_) async {
      await checkConnection();
    });
  }

  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();

      // No Wi-Fi, mobile, ethernet, etc.
      if (results.contains(ConnectivityResult.none)) {
        _updateConnectionStatus(false);
        return false;
      }

      // We have a network interface, now check actual internet access.
      final response = await _httpClient
          .get(Uri.parse(checkUrl))
          .timeout(const Duration(seconds: 5));

      final connected = response.statusCode >= 200 && response.statusCode < 400;

      _updateConnectionStatus(connected);

      return connected;
    } catch (_) {
      _updateConnectionStatus(false);
      return false;
    }
  }

  void _updateConnectionStatus(bool connected) {
    if (_isConnected == connected) {
      return;
    }

    _isConnected = connected;
    _connectionController.add(connected);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _connectionController.close();

    _httpClient.close();
  }
}
