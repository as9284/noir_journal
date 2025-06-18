import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lock/app_lock_manager.dart';
import '../utils/app_lock_service.dart';
import '../utils/restart_widget.dart';
import '../utils/data_operation_dialogs.dart';
import '../utils/password_dialog.dart';
import '../utils/dialog_utils.dart';
import '../main.dart';
import '../widgets/pin_lock_screen.dart';
import '../services/data_export_import_service.dart';
import '../theme/app_theme.dart';

class SettingsController extends ChangeNotifier {
  bool _isDarkTheme = false;
  String _version = '';
  bool _lockEnabled = false;
  bool _biometricEnabled = false;
  bool _isLoading = true;
  AppColorTheme _selectedColorTheme = AppColorTheme.noir;

  bool get isDarkTheme => _isDarkTheme;
  String get version => _version;
  bool get lockEnabled => _lockEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get isLoading => _isLoading;
  AppColorTheme get selectedColorTheme => _selectedColorTheme;

  Future<void> initialize() async {
    await _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkTheme') ?? false;
      final lockEnabled = await AppLockService.isLockEnabled();
      final biometricEnabled = await AppLockService.isBiometricEnabled();
      final colorThemeString = prefs.getString('selectedColorTheme') ?? 'noir';

      // Parse the saved color theme
      AppColorTheme selectedTheme = AppColorTheme.noir;
      try {
        selectedTheme = AppColorTheme.values.firstWhere(
          (theme) => theme.name == colorThemeString,
          orElse: () => AppColorTheme.noir,
        );
      } catch (e) {
        // If parsing fails, use default
        selectedTheme = AppColorTheme.noir;
      }

      _version = packageInfo.version;
      _isDarkTheme = isDark;
      _lockEnabled = lockEnabled;
      _biometricEnabled = biometricEnabled;
      _selectedColorTheme = selectedTheme;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkTheme(
    bool value,
    ValueNotifier<ThemeData> themeNotifier,
  ) async {
    _isDarkTheme = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', value);

    // Update the theme with the current color theme
    themeNotifier.value = getThemeData(
      colorTheme: _selectedColorTheme,
      isDark: value,
    );
  }

  Future<void> changeColorTheme(
    AppColorTheme colorTheme,
    ValueNotifier<ThemeData> themeNotifier,
  ) async {
    _selectedColorTheme = colorTheme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedColorTheme', colorTheme.name);

    // Update the theme with the new color theme
    themeNotifier.value = getThemeData(
      colorTheme: colorTheme,
      isDark: _isDarkTheme,
    );
  }

  Future<bool> enableAppLock(BuildContext context) async {
    if (!context.mounted) return false;

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

      if (!context.mounted) return false;

      await _handleBiometricSetup(context);

      if (!context.mounted) return false;

      await _showRestartDialog(context);
      return true;
    }
    return false;
  }

  Future<bool> disableAppLock(BuildContext context) async {
    if (!context.mounted) return false;

    final storedPin = await AppLockService.getPin();
    final allowBiometric = await AppLockService.isBiometricEnabled();

    if (!context.mounted) return false;

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
    if (!context.mounted) return;

    final localAuth = LocalAuthentication();
    final canCheckBiometrics = await localAuth.canCheckBiometrics;
    final isDeviceSupported = await localAuth.isDeviceSupported();

    if (!canCheckBiometrics || !isDeviceSupported) return;

    if (!context.mounted) return;

    final enableBiometrics = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Enable Biometrics?',
      message:
          'Would you like to enable biometric authentication for faster unlocking?',
      confirmText: 'Enable',
      cancelText: 'Skip',
    );

    if (enableBiometrics == true) {
      await AppLockService.setBiometricEnabled(true);
      _biometricEnabled = true;
      notifyListeners();
    }
  }

  Future<void> _showRestartDialog(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Setup Complete'),
            content: const Text(
              'App lock has been configured. The app will restart to activate the feature.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Store the navigator and context references before async operations
                  final navigator = Navigator.of(dialogContext);
                  final originalContext = context;

                  // Pop the dialog first
                  navigator.pop();

                  // Perform async operations
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('intro_seen', true);

                  // Check if original context is still mounted before restart
                  if (originalContext.mounted) {
                    RestartWidget.restartApp(originalContext);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> exportData(BuildContext context) async {
    try {
      if (!context.mounted) return;

      DataOperationDialogs.showLoadingDialog(
        context,
        'Preparing encrypted export...',
      );

      final result = await DataExportImportService.exportData();

      if (!context.mounted) return;

      DataOperationDialogs.hideLoadingDialog(context);

      if (result.success && result.exportPassword != null) {
        // Show password dialog first
        await PasswordInputDialog.showPasswordCopyDialog(
          context,
          result.exportPassword!,
        );
      }

      if (!context.mounted) return;

      await DataOperationDialogs.showResultDialog(
        context,
        success: result.success,
        title: result.success ? 'Export Successful' : 'Export Failed',
        message:
            result.success
                ? 'Your journal has been exported with encryption. The backup file has been saved to your Downloads folder.'
                : result.message,
      );
    } catch (e) {
      if (!context.mounted) return;

      DataOperationDialogs.hideLoadingDialog(context);

      await DataOperationDialogs.showResultDialog(
        context,
        success: false,
        title: 'Export Error',
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<void> importData(BuildContext context) async {
    final confirmed = await DataOperationDialogs.showImportConfirmation(
      context,
    );
    if (!confirmed) return;

    try {
      if (!context.mounted) return;

      DataOperationDialogs.showLoadingDialog(context, 'Reading backup file...');

      final fileCheck = await DataExportImportService.checkBackupFile();

      if (!context.mounted) return;

      DataOperationDialogs.hideLoadingDialog(context);

      if (!fileCheck.success) {
        await DataOperationDialogs.showResultDialog(
          context,
          success: false,
          title: 'File Selection Error',
          message: fileCheck.message,
        );
        return;
      }

      ImportResult result;
      if (fileCheck.isEncrypted) {
        final password = await PasswordInputDialog.showPasswordDialog(
          context,
          title: 'Enter Backup Password',
          message:
              'This backup is encrypted. Please enter the password you received when you created this backup.',
        );
        if (password != null) {
          if (!context.mounted) return;

          DataOperationDialogs.showLoadingDialog(
            context,
            'Decrypting and importing...',
          );
          result = await DataExportImportService.importFromCheckedFile(
            fileCheck,
            password,
          );

          if (!context.mounted) return;

          DataOperationDialogs.hideLoadingDialog(context);
        } else {
          return;
        }
      } else {
        if (!context.mounted) return;

        DataOperationDialogs.showLoadingDialog(context, 'Importing...');
        result = await DataExportImportService.importFromCheckedFile(fileCheck);

        if (!context.mounted) return;

        DataOperationDialogs.hideLoadingDialog(context);
      }

      if (!context.mounted) return;

      await DataOperationDialogs.showResultDialog(
        context,
        success: result.success,
        title: result.success ? 'Import Successful' : 'Import Failed',
        message: result.message,
      );
      if (result.success) {
        // Trigger global data refresh notifier
        globalDataRefreshNotifier.value++;

        // Small delay to ensure dialog is dismissed and user can see the success message
        await Future.delayed(const Duration(milliseconds: 1000));
        if (!context.mounted) return;

        // Navigate back to home screen completely
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!context.mounted) return;

      DataOperationDialogs.hideLoadingDialog(context);

      await DataOperationDialogs.showResultDialog(
        context,
        success: false,
        title: 'Import Error',
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
