import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class SecurityService {
  static const MethodChannel _channel = MethodChannel('security_service');
  static bool _isSecureModeEnabled = false;
  static Future<void> enableSecureMode() async {
    debugPrint(
      'SecurityService: enableSecureMode called, current state: $_isSecureModeEnabled, platform: ${Platform.operatingSystem}',
    );
    if (Platform.isAndroid && !_isSecureModeEnabled) {
      try {
        debugPrint('SecurityService: Calling enableSecureMode method channel');
        await _channel.invokeMethod('enableSecureMode');
        _isSecureModeEnabled = true;
        debugPrint('SecurityService: Successfully enabled secure mode');
      } catch (e) {
        // Secure mode not available, continue normally
        debugPrint('Failed to enable secure mode: $e');
      }
    } else {
      debugPrint(
        'SecurityService: Skipping enableSecureMode - already enabled or not Android',
      );
    }
  }

  static Future<void> disableSecureMode() async {
    debugPrint(
      'SecurityService: disableSecureMode called, current state: $_isSecureModeEnabled',
    );
    if (Platform.isAndroid && _isSecureModeEnabled) {
      try {
        debugPrint('SecurityService: Calling disableSecureMode method channel');
        await _channel.invokeMethod('disableSecureMode');
        _isSecureModeEnabled = false;
        debugPrint('SecurityService: Successfully disabled secure mode');
      } catch (e) {
        // Secure mode not available, continue normally
        debugPrint('Failed to disable secure mode: $e');
      }
    } else {
      debugPrint(
        'SecurityService: Skipping disableSecureMode - already disabled or not Android',
      );
    }
  }

  static bool get isSecureModeEnabled => _isSecureModeEnabled;
}
