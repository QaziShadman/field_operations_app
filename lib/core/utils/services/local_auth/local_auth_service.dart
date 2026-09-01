import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthServices {
  LocalAuthServices({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  Future<bool> authenticateForPhoto() async {
    try {
      final isDeviceSupported = await _localAuthentication.isDeviceSupported();
      if (!isDeviceSupported) {
        return true;
      }

      return await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to view the job visit photo attachment',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException {
      return false;
    } catch (e) {
      return false;
    }
  }
}
