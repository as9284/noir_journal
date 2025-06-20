import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_lock_service.dart';
import '../widgets/app_lock_screen.dart';

class AppLockManager {
  static bool _isLockScreenVisible = false;

  static Future<bool> requireAuthentication(
    BuildContext context, {
    String title = 'App Locked',
    String subtitle = 'Enter your PIN to continue',
    bool showCancelButton = false,
    String cancelButtonText = 'Cancel',
    Future<bool> Function()? onCancel,
  }) async {
    if (_isLockScreenVisible || !context.mounted) {
      return false;
    }

    final enabled = await AppLockService.isLockEnabled();
    if (!enabled) return true;

    _isLockScreenVisible = true;

    try {
      final allowBiometric = await AppLockService.isBiometricEnabled();

      if (!context.mounted) {
        _isLockScreenVisible = false;
        return false;
      }

      final result = await Navigator.of(context).push<AppLockAction>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder:
              (_) => AppLockScreen(
                title: title,
                subtitle: subtitle,
                showCancelButton: showCancelButton,
                cancelButtonText: cancelButtonText,
                onCancel: onCancel,
                allowBiometric: allowBiometric,
              ),
        ),
      );

      _isLockScreenVisible = false;
      return result == AppLockAction.unlock;
    } catch (e) {
      _isLockScreenVisible = false;
      return false;
    }
  }

  static Future<bool> requireAuthenticationForApp(BuildContext context) async {
    return await requireAuthentication(
      context,
      title: 'App Locked',
      subtitle: 'Enter your PIN to unlock the app',
      showCancelButton: true,
      cancelButtonText: 'Exit',
      onCancel: () async {
        SystemNavigator.pop();
        return false;
      },
    );
  }

  static Future<bool> requireAuthenticationForOperation(
    BuildContext context,
    String operationName,
  ) async {
    return await requireAuthentication(
      context,
      title: 'Authentication Required',
      subtitle: 'Enter your PIN to $operationName',
      showCancelButton: true,
      cancelButtonText: 'Cancel',
    );
  }

  static Future<bool> requireAuthenticationForSensitiveOperation(
    BuildContext context,
    String operationName,
  ) async {
    return await requireAuthentication(
      context,
      title: 'Confirm Identity',
      subtitle: 'Enter your PIN to $operationName',
      showCancelButton: true,
      cancelButtonText: 'Cancel',
    );
  }

  static Future<bool> requireAuthenticationForDataOperation(
    BuildContext context,
    String operationName,
  ) async {
    return await requireAuthentication(
      context,
      title: 'Secure Data Access',
      subtitle: 'Enter your PIN to $operationName',
      showCancelButton: true,
      cancelButtonText: 'Cancel',
    );
  }

  static bool get isLockScreenVisible => _isLockScreenVisible;
}
