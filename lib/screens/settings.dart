import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/ui_constants.dart';
import '../lock/app_lock_manager.dart';
import '../utils/app_lock_service.dart';
import '../utils/settings_prefs.dart';
import '../utils/restart_widget.dart';
import '../main.dart';
import '../widgets/pin_lock_screen.dart';

class SettingsPage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;
  const SettingsPage({super.key, required this.themeModeNotifier});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkTheme = false;
  String _version = '';
  bool _lockEnabled = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    final version = await PackageInfo.fromPlatform();
    final isDark = await SettingsPrefs.getDarkTheme();
    final lockEnabled = await AppLockService.isLockEnabled();
    final biometricEnabled = await AppLockService.isBiometricEnabled();
    setState(() {
      _version = version.version;
      _isDarkTheme = isDark;
      _lockEnabled = lockEnabled;
      _biometricEnabled = biometricEnabled;
    });
  }

  Future<void> _toggleDarkTheme(bool value) async {
    setState(() {
      _isDarkTheme = value;
    });
    await SettingsPrefs.setDarkTheme(value);
    widget.themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _toggleAppLock(bool value) async {
    if (value) {
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
        setState(() {
          _lockEnabled = true;
        });

        if (mounted) {
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
              setState(() {
                _biometricEnabled = true;
              });
            }
          } // Show restart dialog
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

                        // Ensure intro is marked as seen before restart
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
    } else {
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
        setState(() {
          _lockEnabled = false;
          _biometricEnabled = false;
        });
        globalAppLockNotifier.value = false;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('App lock not disabled.')));
      }
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final localAuth = LocalAuthentication();
      final canCheck = await localAuth.canCheckBiometrics;
      if (canCheck) {
        await AppLockService.setBiometricEnabled(true);
        setState(() {
          _biometricEnabled = true;
        });
      }
    } else {
      await AppLockService.setBiometricEnabled(false);
      setState(() {
        _biometricEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        titleSpacing: DiaryPaddings.horizontal,
        actions: const [SizedBox(width: DiaryPaddings.horizontal)],
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: _isDarkTheme,
            onChanged: _toggleDarkTheme,
            secondary: const Icon(Icons.dark_mode),
          ),
          SwitchListTile(
            title: const Text('App Lock'),
            value: _lockEnabled,
            onChanged: _toggleAppLock,
            secondary: const Icon(Icons.lock),
          ),
          if (_lockEnabled)
            SwitchListTile(
              title: const Text('Enable Biometrics'),
              value: _biometricEnabled,
              onChanged: _toggleBiometric,
              secondary: const Icon(Icons.fingerprint),
            ),
          const Divider(endIndent: 15, indent: 15),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: Text(_version.isEmpty ? 'Loading...' : _version),
          ),
        ],
      ),
    );
  }
}
