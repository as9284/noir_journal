import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lock/app_lock_manager.dart';
import '../utils/app_lock_service.dart';
import '../utils/settings_prefs.dart';
import '../utils/restart_widget.dart';
import '../main.dart';
import '../widgets/pin_lock_screen.dart';

class SettingsController extends ChangeNotifier {
  bool _isDarkTheme = false;
  String _version = '';
  bool _lockEnabled = false;
  bool _biometricEnabled = false;
  bool _isLoading = true;

  bool get isDarkTheme => _isDarkTheme;
  String get version => _version;
  bool get lockEnabled => _lockEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    await _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final isDark = await SettingsPrefs.getDarkTheme();
      final lockEnabled = await AppLockService.isLockEnabled();
      final biometricEnabled = await AppLockService.isBiometricEnabled();

      _version = packageInfo.version;
      _isDarkTheme = isDark;
      _lockEnabled = lockEnabled;
      _biometricEnabled = biometricEnabled;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkTheme(
    bool value,
    ValueNotifier<ThemeMode> themeModeNotifier,
  ) async {
    _isDarkTheme = value;
    notifyListeners();

    await SettingsPrefs.setDarkTheme(value);
    themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  Future<bool> enableAppLock(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (_) => PinLockScreen(
              registerMode: true,
              onRegister: (pin) async {
                await AppLockService.setPin(pin);
              },
            ),
      ),
    );

    if (result == true) {
      globalAppLockNotifier.value = true;
      _lockEnabled = true;
      notifyListeners();

      if (context.mounted) {
        await _handleBiometricSetup(context);
        await _showRestartDialog(context);
      }
      return true;
    }
    return false;
  }

  Future<bool> disableAppLock(BuildContext context) async {
    final storedPin = await AppLockService.getPin();
    final allowBiometric = await AppLockService.isBiometricEnabled();

    AppLockManager.isLockScreenVisible = true;
    final unlocked = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (_) => PinLockScreen(
              onVerify: (input) async => input == storedPin,
              allowBiometric: allowBiometric,
            ),
      ),
    );
    AppLockManager.isLockScreenVisible = false;

    if (unlocked == true) {
      await AppLockService.clearPin();
      await AppLockService.setBiometricEnabled(false);
      _lockEnabled = false;
      _biometricEnabled = false;
      globalAppLockNotifier.value = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> toggleBiometric(bool value) async {
    if (value) {
      final localAuth = LocalAuthentication();
      final canCheck = await localAuth.canCheckBiometrics;
      if (canCheck) {
        await AppLockService.setBiometricEnabled(true);
        _biometricEnabled = true;
        notifyListeners();
      }
    } else {
      await AppLockService.setBiometricEnabled(false);
      _biometricEnabled = false;
      notifyListeners();
    }
  }

  Future<void> _handleBiometricSetup(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final canCheckBiometrics = await localAuth.canCheckBiometrics;
    final isDeviceSupported = await localAuth.isDeviceSupported();

    if (canCheckBiometrics && isDeviceSupported) {
      final enableBiometrics = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text('Enable Biometrics?'),
              content: const Text(
                'Would you like to enable biometric authentication for faster unlocking?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Skip'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Enable'),
                ),
              ],
            ),
      );

      if (enableBiometrics == true) {
        await AppLockService.setBiometricEnabled(true);
        _biometricEnabled = true;
        notifyListeners();
      }
    }
  }

  Future<void> _showRestartDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Setup Complete'),
            content: const Text(
              'App lock has been configured. The app will restart to activate the feature.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('intro_seen', true);
                  RestartWidget.restartApp(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
