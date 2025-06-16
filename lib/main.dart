import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noir_journal/screens/home.dart';
import 'package:noir_journal/screens/intro.dart';
import 'package:noir_journal/screens/settings.dart';
import 'package:noir_journal/theme/app_theme.dart';
import 'utils/orientation_lock.dart';

ValueNotifier<ThemeMode>? globalThemeModeNotifier;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lockPortraitMode();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkTheme') ?? false;
  globalThemeModeNotifier = ValueNotifier(
    isDark ? ThemeMode.dark : ThemeMode.light,
  );
  runApp(MainApp(themeModeNotifier: globalThemeModeNotifier!));
}

class MainApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;
  const MainApp({super.key, required this.themeModeNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: const IntroScreen(),
          routes: {
            '/home': (context) => const HomePage(),
            '/settings':
                (context) =>
                    SettingsPage(themeModeNotifier: globalThemeModeNotifier!),
          },
        );
      },
    );
  }
}
