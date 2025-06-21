import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_storage_config.dart';

class AppLockService {
  static const _pinKey = 'app_lock_pin';
  static const _lockEnabledKey = 'app_lock_enabled';
  static const _biometricEnabledKey = 'app_lock_biometric';
  static const _screenshotProtectionKey = 'screenshot_protection_enabled';
  static const _failedAttemptsKey = 'app_lock_failed_attempts';
  static const _lockdownUntilKey = 'app_lock_lockdown_until';

  static const int maxAttemptsBeforeLockdown = 10;
  static const int lockdownDurationSeconds = 5;

  // Use the shared storage configuration to ensure compatibility
  static const FlutterSecureStorage _storage = SecureStorageConfig.storage;

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

  static Future<void> setScreenshotProtectionEnabled(bool enabled) async {
    await _storage.write(
      key: _screenshotProtectionKey,
      value: enabled ? 'true' : 'false',
    );
  }

  static Future<bool> isScreenshotProtectionEnabled() async {
    final value = await _storage.read(key: _screenshotProtectionKey);
    return value == 'true';
  }

  /// Get current failed attempts count
  static Future<int> getFailedAttempts() async {
    final value = await _storage.read(key: _failedAttemptsKey);
    return int.tryParse(value ?? '0') ?? 0;
  }

  /// Increment failed attempts counter
  static Future<void> incrementFailedAttempts() async {
    final currentAttempts = await getFailedAttempts();

    await _storage.write(
      key: _failedAttemptsKey,
      value: (currentAttempts + 1).toString(),
    );

    // Check if we need to trigger lockdown
    if (currentAttempts + 1 >= maxAttemptsBeforeLockdown) {
      await _triggerLockdown();
    }
  }

  /// Reset failed attempts counter (after successful unlock)
  static Future<void> resetFailedAttempts() async {
    await _storage.delete(key: _failedAttemptsKey);
  }

  /// Trigger lockdown for specified duration
  static Future<void> _triggerLockdown() async {
    final lockdownUntil = DateTime.now().add(
      Duration(seconds: lockdownDurationSeconds),
    );
    await _storage.write(
      key: _lockdownUntilKey,
      value: lockdownUntil.millisecondsSinceEpoch.toString(),
    );
    // Reset current session failed attempts
    await _storage.delete(key: _failedAttemptsKey);
  }

  /// Check if app is currently in lockdown
  static Future<bool> isInLockdown() async {
    final value = await _storage.read(key: _lockdownUntilKey);
    if (value == null) return false;

    final lockdownUntil = DateTime.fromMillisecondsSinceEpoch(int.parse(value));
    final isStillLocked = DateTime.now().isBefore(lockdownUntil);

    if (!isStillLocked) {
      // Lockdown expired, clear it
      await _storage.delete(key: _lockdownUntilKey);
    }

    return isStillLocked;
  }

  /// Get remaining lockdown time in seconds
  static Future<int> getLockdownRemainingSeconds() async {
    final value = await _storage.read(key: _lockdownUntilKey);
    if (value == null) return 0;

    final lockdownUntil = DateTime.fromMillisecondsSinceEpoch(int.parse(value));
    final remaining = lockdownUntil.difference(DateTime.now());

    return remaining.inSeconds > 0 ? remaining.inSeconds : 0;
  }
}
