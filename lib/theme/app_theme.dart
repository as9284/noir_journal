import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final entryCardLightColor = const Color(0xFFF8F8F8);
final entryCardDarkColor = const Color(0xFF23232A).withValues(alpha: 235 / 255);

// Color theme options
enum AppColorTheme {
  noir, // Default black/white theme
  blue,
  purple,
  green,
  orange,
  red,
  pink,
  teal,
}

// Color theme data structure
class ColorThemeData {
  final String name;
  final Color lightPrimary;
  final Color darkPrimary;
  final Color lightSecondary;
  final Color darkSecondary;
  final Color lightSurface;
  final Color darkSurface;
  final Color lightBackground;
  final Color darkBackground;

  const ColorThemeData({
    required this.name,
    required this.lightPrimary,
    required this.darkPrimary,
    required this.lightSecondary,
    required this.darkSecondary,
    required this.lightSurface,
    required this.darkSurface,
    required this.lightBackground,
    required this.darkBackground,
  });
}

// Available color themes
final Map<AppColorTheme, ColorThemeData> colorThemes = {
  AppColorTheme.noir: const ColorThemeData(
    name: 'Noir (Default)',
    lightPrimary: Colors.black,
    darkPrimary: Colors.white,
    lightSecondary: Colors.white,
    darkSecondary: Colors.black,
    lightSurface: Colors.white,
    darkSurface: Colors.black,
    lightBackground: Colors.white,
    darkBackground: Colors.black,
  ),
  AppColorTheme.blue: const ColorThemeData(
    name: 'Ocean Blue',
    lightPrimary: Color(0xFF1976D2),
    darkPrimary: Color(0xFF64B5F6),
    lightSecondary: Color(0xFFE3F2FD),
    darkSecondary: Color(0xFF0D47A1),
    lightSurface: Color(0xFFFAFAFA),
    darkSurface: Color(0xFF121212),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.purple: const ColorThemeData(
    name: 'Royal Purple',
    lightPrimary: Color(0xFF7B1FA2),
    darkPrimary: Color(0xFFBA68C8),
    lightSecondary: Color(0xFFF3E5F5),
    darkSecondary: Color(0xFF4A148C),
    lightSurface: Color(0xFFFAFAFA),
    darkSurface: Color(0xFF121212),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.green: const ColorThemeData(
    name: 'Forest Green',
    lightPrimary: Color(0xFF388E3C),
    darkPrimary: Color(0xFF81C784),
    lightSecondary: Color(0xFFE8F5E8),
    darkSecondary: Color(0xFF1B5E20),
    lightSurface: Color(0xFFFAFAFA),
    darkSurface: Color(0xFF121212),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.orange: const ColorThemeData(
    name: 'Sunset Orange',
    lightPrimary: Color(0xFFF57C00),
    darkPrimary: Color(0xFFFFB74D),
    lightSecondary: Color(0xFFFFF3E0),
    darkSecondary: Color(0xFFE65100),
    lightSurface: Color(0xFFFAFAFA),
    darkSurface: Color(0xFF121212),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.red: const ColorThemeData(
    name: 'Cherry Red',
    lightPrimary: Color(0xFFD32F2F),
    darkPrimary: Color(0xFFEF5350),
    lightSecondary: Color(0xFFFFEBEE),
    darkSecondary: Color(0xFFB71C1C),
    lightSurface: Color(0xFFFAFAFA),
    darkSurface: Color(0xFF121212),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.pink: const ColorThemeData(
    name: 'Rose Pink',
    lightPrimary: Color(0xFFC2185B),
    darkPrimary: Color(0xFFF06292),
    lightSecondary: Color(0xFFFCE4EC),
    darkSecondary: Color(0xFF880E4F),
    lightSurface: Color(0xFFFAFAFA),
    darkSurface: Color(0xFF121212),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.teal: const ColorThemeData(
    name: 'Mystic Teal',
    lightPrimary: Color(0xFF00796B),
    darkPrimary: Color(0xFF4DB6AC),
    lightSecondary: Color(0xFFE0F2F1),
    darkSecondary: Color(0xFF004D40),
    lightSurface: Color(0xFFFAFAFA),
    darkSurface: Color(0xFF121212),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
};

// Function to get theme data based on color theme and brightness
ThemeData getThemeData({
  required AppColorTheme colorTheme,
  required bool isDark,
}) {
  final colorData = colorThemes[colorTheme]!;

  if (isDark) {
    return _buildDarkTheme(colorData);
  } else {
    return _buildLightTheme(colorData);
  }
}

ThemeData _buildLightTheme(ColorThemeData colorData) {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: colorData.lightPrimary,
    scaffoldBackgroundColor: colorData.lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: colorData.lightBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: colorData.lightPrimary),
      titleTextStyle: TextStyle(
        color: colorData.lightPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: colorData.lightPrimary, fontSize: 16),
      bodyMedium: TextStyle(
        color: colorData.lightPrimary.withValues(alpha: 0.87),
        fontSize: 14,
      ),
      titleLarge: TextStyle(
        color: colorData.lightPrimary,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: colorData.lightPrimary,
      onPrimary: colorData.lightSecondary,
      secondary: colorData.lightSecondary,
      onSecondary: colorData.lightPrimary,
      surface: colorData.lightSurface,
      onSurface: colorData.lightPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorData.lightPrimary,
        foregroundColor: colorData.lightSecondary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorData.lightPrimary,
        backgroundColor: Colors.transparent,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorData.lightPrimary,
        backgroundColor: Colors.transparent,
        side: BorderSide(color: colorData.lightPrimary, width: 1.5),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    inputDecorationTheme: const InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colorData.lightBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: TextStyle(
        color: colorData.lightPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: colorData.lightPrimary.withValues(alpha: 0.87),
        fontSize: 16,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 40.0,
        vertical: 24.0,
      ),
    ),
  );
}

ThemeData _buildDarkTheme(ColorThemeData colorData) {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: colorData.darkPrimary,
    scaffoldBackgroundColor: colorData.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: colorData.darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: colorData.darkPrimary),
      titleTextStyle: TextStyle(
        color: colorData.darkPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: colorData.darkPrimary, fontSize: 16),
      bodyMedium: TextStyle(
        color: colorData.darkPrimary.withValues(alpha: 0.7),
        fontSize: 14,
      ),
      titleLarge: TextStyle(
        color: colorData.darkPrimary,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: colorData.darkPrimary,
      onPrimary: colorData.darkSecondary,
      secondary: colorData.darkSecondary,
      onSecondary: colorData.darkPrimary,
      surface: colorData.darkSurface,
      onSurface: colorData.darkPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorData.darkPrimary,
        foregroundColor: colorData.darkSecondary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorData.darkPrimary,
        backgroundColor: Colors.transparent,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorData.darkPrimary,
        backgroundColor: Colors.transparent,
        side: BorderSide(color: colorData.darkPrimary, width: 1.5),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    inputDecorationTheme: const InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colorData.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: TextStyle(
        color: colorData.darkPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: colorData.darkPrimary.withValues(alpha: 0.87),
        fontSize: 16,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 40.0,
        vertical: 24.0,
      ),
    ),
  );
}

// Legacy theme exports for backward compatibility
final ThemeData lightTheme = getThemeData(
  colorTheme: AppColorTheme.noir,
  isDark: false,
);
final ThemeData darkTheme = getThemeData(
  colorTheme: AppColorTheme.noir,
  isDark: true,
);
