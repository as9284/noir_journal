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

ValueNotifier<ThemeMode>? globalThemeModeNotifier;
ValueNotifier<bool> globalAppLockNotifier = ValueNotifier(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lockPortraitMode();
  await initializeAppLockNotifier();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkTheme') ?? false;
  globalThemeModeNotifier = ValueNotifier(
    isDark ? ThemeMode.dark : ThemeMode.light,
  );
  runApp(
    RestartWidget(child: MainApp(themeModeNotifier: globalThemeModeNotifier!)),
  );
}

Future<void> initializeAppLockNotifier() async {
  final enabled = await AppLockService.isLockEnabled();
  globalAppLockNotifier.value = enabled;
}

class MainApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;
  const MainApp({super.key, required this.themeModeNotifier});

  Future<bool> _shouldShowIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('intro_seen') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return FutureBuilder<bool>(
          future: _shouldShowIntro(),
          builder: (context, snapshot) {
            final showIntro = snapshot.data ?? false;

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeMode,
              home: LockWrapper(
                child: showIntro ? const IntroScreen() : const HomePage(),
              ),
              routes: {
                '/home': (context) => const HomePage(),
                '/settings':
                    (context) => SettingsPage(
                      themeModeNotifier: globalThemeModeNotifier!,
                    ),
              },
            );
          },
        );
      },
    );
  }
}
