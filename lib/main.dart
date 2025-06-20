import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noir_journal/screens/home.dart';
import 'package:noir_journal/screens/intro.dart';
import 'package:noir_journal/screens/settings.dart';
import 'package:noir_journal/theme/app_theme.dart';

import 'utils/orientation_lock.dart';
import 'utils/restart_widget.dart';
import 'lock/lock_wrapper.dart';
import 'utils/app_lock_service.dart';
import 'utils/security_service.dart';
import 'widgets/security_overlay.dart';
import 'services/encryption_service.dart';

ValueNotifier<ThemeData>? globalThemeNotifier;
ValueNotifier<bool> globalAppLockNotifier = ValueNotifier(false);
ValueNotifier<bool> globalScreenshotProtectionNotifier = ValueNotifier(false);
ValueNotifier<int> globalDataRefreshNotifier = ValueNotifier(0);
ValueNotifier<bool> globalFileOperationInProgress = ValueNotifier(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lockPortraitMode();
  await initializeAppLockNotifier();
  await initializeScreenshotProtectionNotifier();

  // Initialize secure encryption
  await EncryptionService.migrateToSecureEncryption();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkTheme') ?? false;
  final colorThemeString = prefs.getString('selectedColorTheme') ?? 'noir';
  final fontFamilyString =
      prefs.getString('selectedFontFamily') ?? 'defaultFont';

  AppColorTheme selectedTheme = AppColorTheme.noir;
  try {
    selectedTheme = AppColorTheme.values.firstWhere(
      (theme) => theme.name == colorThemeString,
      orElse: () => AppColorTheme.noir,
    );
  } catch (e) {
    selectedTheme = AppColorTheme.noir;
  }
  AppFontFamily selectedFontFamily = AppFontFamily.inter;
  try {
    selectedFontFamily = AppFontFamily.values.firstWhere(
      (font) => font.name == fontFamilyString,
      orElse: () => AppFontFamily.inter,
    );
  } catch (e) {
    selectedFontFamily = AppFontFamily.inter;
  }

  globalThemeNotifier = ValueNotifier(
    getThemeData(
      colorTheme: selectedTheme,
      isDark: isDark,
      fontFamily: selectedFontFamily,
    ),
  );

  runApp(RestartWidget(child: MainApp(themeNotifier: globalThemeNotifier!)));
}

Future<void> initializeAppLockNotifier() async {
  try {
    final enabled = await AppLockService.isLockEnabled();
    globalAppLockNotifier.value = enabled;

    if (enabled) {
      final pin = await AppLockService.getPin();
      if (pin == null || pin.isEmpty) {
        await AppLockService.setLockEnabled(false);
        globalAppLockNotifier.value = false;
      }
    }
  } catch (e) {
    globalAppLockNotifier.value = false;
  }
}

Future<void> initializeScreenshotProtectionNotifier() async {
  try {
    final enabled = await AppLockService.isScreenshotProtectionEnabled();
    globalScreenshotProtectionNotifier.value = enabled;

    // Apply screenshot protection immediately if enabled
    if (enabled) {
      await SecurityService.enableSecureMode();
    }

    // Add listener to handle changes
    globalScreenshotProtectionNotifier.addListener(() async {
      if (globalScreenshotProtectionNotifier.value) {
        await SecurityService.enableSecureMode();
      } else {
        await SecurityService.disableSecureMode();
      }
    });
  } catch (e) {
    globalScreenshotProtectionNotifier.value = false;
  }
}

class MainApp extends StatelessWidget {
  final ValueNotifier<ThemeData> themeNotifier;
  const MainApp({super.key, required this.themeNotifier});

  Future<bool> _shouldShowIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('intro_seen') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: themeNotifier,
      builder: (context, theme, _) {
        return FutureBuilder<bool>(
          future: _shouldShowIntro(),
          builder: (context, snapshot) {
            final showIntro = snapshot.hasData ? snapshot.data! : false;
            return ValueListenableBuilder<bool>(
              valueListenable: globalAppLockNotifier,
              builder: (context, appLockEnabled, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: globalScreenshotProtectionNotifier,
                  builder: (context, screenshotProtectionEnabled, _) {
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      theme: theme,
                      home: SecurityOverlay(
                        enabled: appLockEnabled,
                        screenshotProtectionEnabled:
                            screenshotProtectionEnabled,
                        child: LockWrapper(
                          child:
                              showIntro
                                  ? const IntroScreen()
                                  : const HomePage(),
                        ),
                      ),
                      routes: {
                        '/home':
                            (context) => SecurityOverlay(
                              enabled: appLockEnabled,
                              screenshotProtectionEnabled:
                                  screenshotProtectionEnabled,
                              child: const LockWrapper(child: HomePage()),
                            ),
                        '/settings':
                            (context) => SecurityOverlay(
                              enabled: appLockEnabled,
                              screenshotProtectionEnabled:
                                  screenshotProtectionEnabled,
                              child: SettingsPage(
                                themeNotifier: globalThemeNotifier!,
                              ),
                            ),
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
