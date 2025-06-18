import 'package:flutter/material.dart';
import '../utils/app_lock_service.dart';
import '../widgets/pin_lock_screen.dart';

class AppLockManager {
  static bool isLockScreenVisible = false;
  static Future<bool> checkAndUnlock(BuildContext context) async {
    if (isLockScreenVisible || !context.mounted) return false;

    final enabled = await AppLockService.isLockEnabled();
    if (!enabled) return true;

    isLockScreenVisible = true;

    try {
      final pin = await AppLockService.getPin();
      final allowBiometric = await AppLockService.isBiometricEnabled();

      if (!context.mounted) {
        isLockScreenVisible = false;
        return false;
      }

      final unlocked = await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder:
              (_) => PinLockScreen(
                onVerify: (input) async => input == pin,
                allowBiometric: allowBiometric,
              ),
        ),
      );

      isLockScreenVisible = false;
      return unlocked == true;
    } catch (e) {
      isLockScreenVisible = false;
      return false;
    }
  }
}
