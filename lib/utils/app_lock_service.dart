import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppLockService {
  static const _pinKey = 'app_lock_pin';
  static const _lockEnabledKey = 'app_lock_enabled';
  static const _biometricEnabledKey = 'app_lock_biometric';
  static final _storage = FlutterSecureStorage();

  static Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    await setLockEnabled(true);
  }

  static Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  static Future<void> setLockEnabled(bool enabled) async {
    await _storage.write(
      key: _lockEnabledKey,
      value: enabled ? 'true' : 'false',
    );
  }

  static Future<bool> isLockEnabled() async {
    final value = await _storage.read(key: _lockEnabledKey);
    return value == 'true';
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _biometricEnabledKey,
      value: enabled ? 'true' : 'false',
    );
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  static Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
    await setLockEnabled(false);
    await setBiometricEnabled(false);
  }
}
