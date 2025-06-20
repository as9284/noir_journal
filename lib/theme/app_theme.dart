import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/font_manager.dart';

// Available font families for the journal app
enum AppFontFamily { inter, roboto, opensans, lato, sourcesans, nunito }

// Font family data
class FontFamilyData {
  final String name;
  final String fontFamily;
  final String description;

  const FontFamilyData({
    required this.name,
    required this.fontFamily,
    required this.description,
  });
}

// Available fonts with their data
const Map<AppFontFamily, FontFamilyData> appFonts = {
  AppFontFamily.inter: FontFamilyData(
    name: 'Inter',
    fontFamily: 'inter',
    description: 'Modern and highly readable font',
  ),
  AppFontFamily.roboto: FontFamilyData(
    name: 'Roboto',
    fontFamily: 'roboto',
    description: 'Clean and friendly geometric sans-serif',
  ),
  AppFontFamily.opensans: FontFamilyData(
    name: 'Open Sans',
    fontFamily: 'opensans',
    description: 'Humanist sans-serif optimized for legibility',
  ),
  AppFontFamily.lato: FontFamilyData(
    name: 'Lato',
    fontFamily: 'lato',
    description: 'Semi-rounded humanist sans-serif',
  ),
  AppFontFamily.sourcesans: FontFamilyData(
    name: 'Source Sans Pro',
    fontFamily: 'sourcesans',
    description: 'Clean and professional sans-serif',
  ),
  AppFontFamily.nunito: FontFamilyData(
    name: 'Nunito',
    fontFamily: 'nunito',
    description: 'Well-balanced and readable rounded sans-serif',
  ),
};

// Entry card colors that adapt to themes
Color getEntryCardColor(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  if (isDark) {
    return theme.colorScheme.surface;
  } else {
    return theme.colorScheme.surface;
  }
}

Color getEntryCardBorderColor(BuildContext context) {
  final theme = Theme.of(context);
  return theme.colorScheme.outline.withValues(alpha: 0.2);
}

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

// Available color themes with improved contrast
final Map<AppColorTheme, ColorThemeData> colorThemes = {
  AppColorTheme.noir: const ColorThemeData(
    name: 'Noir (Default)',
    lightPrimary: Color(0xFF1A1A1A),
    darkPrimary: Color(0xFFE8E8E8),
    lightSecondary: Color(0xFFF5F5F5),
    darkSecondary: Color(0xFF2A2A2A),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF1E1E1E),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.blue: const ColorThemeData(
    name: 'Ocean Blue',
    lightPrimary: Color(0xFF1565C0),
    darkPrimary: Color(0xFF90CAF9),
    lightSecondary: Color(0xFFE3F2FD),
    darkSecondary: Color(0xFF0D47A1),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF1E1E1E),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.purple: const ColorThemeData(
    name: 'Royal Purple',
    lightPrimary: Color(0xFF6A1B9A),
    darkPrimary: Color(0xFFCE93D8),
    lightSecondary: Color(0xFFF3E5F5),
    darkSecondary: Color(0xFF4A148C),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF1E1E1E),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.green: const ColorThemeData(
    name: 'Forest Green',
    lightPrimary: Color(0xFF2E7D32),
    darkPrimary: Color(0xFFA5D6A7),
    lightSecondary: Color(0xFFE8F5E8),
    darkSecondary: Color(0xFF1B5E20),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF1E1E1E),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.orange: const ColorThemeData(
    name: 'Sunset Orange',
    lightPrimary: Color(0xFFEF6C00),
    darkPrimary: Color(0xFFFFCC02),
    lightSecondary: Color(0xFFFFF3E0),
    darkSecondary: Color(0xFFE65100),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF1E1E1E),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.red: const ColorThemeData(
    name: 'Cherry Red',
    lightPrimary: Color(0xFFC62828),
    darkPrimary: Color(0xFFEF5350),
    lightSecondary: Color(0xFFFFEBEE),
    darkSecondary: Color(0xFFB71C1C),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF1E1E1E),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.pink: const ColorThemeData(
    name: 'Rose Pink',
    lightPrimary: Color(0xFFAD1457),
    darkPrimary: Color(0xFFF48FB1),
    lightSecondary: Color(0xFFFCE4EC),
    darkSecondary: Color(0xFF880E4F),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF1E1E1E),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
  AppColorTheme.teal: const ColorThemeData(
    name: 'Mystic Teal',
    lightPrimary: Color(0xFF00695C),
    darkPrimary: Color(0xFF80CBC4),
    lightSecondary: Color(0xFFE0F2F1),
    darkSecondary: Color(0xFF004D40),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF1E1E1E),
    lightBackground: Color(0xFFFAFAFA),
    darkBackground: Color(0xFF121212),
  ),
};

// Helper function to get font family string
String? _getFontFamily(dynamic fontFamily) {
  if (fontFamily == null) return FontManager.getFontFamily(AppFontFamily.inter);

  if (fontFamily is AppFontFamily) {
    return FontManager.getFontFamily(fontFamily);
  }

  return FontManager.getFontFamily(AppFontFamily.inter); // Default to Inter
}

// Function to get theme data based on color theme and brightness
ThemeData getThemeData({
  required AppColorTheme colorTheme,
  required bool isDark,
  dynamic fontFamily,
}) {
  final colorData = colorThemes[colorTheme]!;

  if (isDark) {
    return _buildDarkTheme(colorData, fontFamily);
  } else {
    return _buildLightTheme(colorData, fontFamily);
  }
}

ThemeData _buildLightTheme(ColorThemeData colorData, [dynamic fontFamily]) {
  final selectedFontFamily = _getFontFamily(fontFamily);
  final colorScheme = ColorScheme.light(
    primary: colorData.lightPrimary,
    onPrimary: colorData.lightSecondary,
    secondary: colorData.lightPrimary.withValues(alpha: 0.7),
    onSecondary: colorData.lightSecondary,
    surface: colorData.lightSurface,
    onSurface: colorData.lightPrimary,
    outline: colorData.lightPrimary.withValues(alpha: 0.3),
    surfaceContainerHighest: colorData.lightSecondary,
    onSurfaceVariant: colorData.lightPrimary.withValues(alpha: 0.7),
  );

  return ThemeData(
    brightness: Brightness.light,
    primaryColor: colorData.lightPrimary,
    scaffoldBackgroundColor: colorData.lightBackground,
    cardColor: colorData.lightSurface,
    colorScheme: colorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorData.lightBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: colorData.lightPrimary),
      titleTextStyle: TextStyle(
        color: colorData.lightPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: selectedFontFamily,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: colorData.lightPrimary,
        fontSize: 16,
        fontFamily: selectedFontFamily,
      ),
      bodyMedium: TextStyle(
        color: colorData.lightPrimary.withValues(alpha: 0.87),
        fontSize: 14,
        fontFamily: selectedFontFamily,
      ),
      bodySmall: TextStyle(
        color: colorData.lightPrimary.withValues(alpha: 0.6),
        fontSize: 12,
        fontFamily: selectedFontFamily,
      ),
      titleLarge: TextStyle(
        color: colorData.lightPrimary,
        fontWeight: FontWeight.bold,
        fontFamily: selectedFontFamily,
      ),
      headlineSmall: TextStyle(
        color: colorData.lightPrimary,
        fontWeight: FontWeight.bold,
        fontFamily: selectedFontFamily,
      ),
      titleMedium: TextStyle(
        color: colorData.lightPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: selectedFontFamily,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorData.lightPrimary,
        foregroundColor: colorData.lightSecondary,
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: selectedFontFamily,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorData.lightPrimary,
        backgroundColor: Colors.transparent,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: selectedFontFamily,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorData.lightPrimary,
        backgroundColor: Colors.transparent,
        side: BorderSide(color: colorData.lightPrimary, width: 1.5),
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: selectedFontFamily,
        ),
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
        fontFamily: selectedFontFamily,
      ),
      contentTextStyle: TextStyle(
        color: colorData.lightPrimary.withValues(alpha: 0.87),
        fontSize: 16,
        fontFamily: selectedFontFamily,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 40.0,
        vertical: 24.0,
      ),
    ),
  );
}

ThemeData _buildDarkTheme(ColorThemeData colorData, [dynamic fontFamily]) {
  final selectedFontFamily = _getFontFamily(fontFamily);
  final colorScheme = ColorScheme.dark(
    primary: colorData.darkPrimary,
    onPrimary: colorData.darkSecondary,
    secondary: colorData.darkPrimary.withValues(alpha: 0.7),
    onSecondary: colorData.darkSecondary,
    surface: colorData.darkSurface,
    onSurface: colorData.darkPrimary,
    outline: colorData.darkPrimary.withValues(alpha: 0.3),
    surfaceContainerHighest: colorData.darkSecondary.withValues(alpha: 0.8),
    onSurfaceVariant: colorData.darkPrimary.withValues(alpha: 0.7),
  );

  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: colorData.darkPrimary,
    scaffoldBackgroundColor: colorData.darkBackground,
    cardColor: colorData.darkSurface,
    colorScheme: colorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorData.darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: colorData.darkPrimary),
      titleTextStyle: TextStyle(
        color: colorData.darkPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: selectedFontFamily,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: colorData.darkPrimary,
        fontSize: 16,
        fontFamily: selectedFontFamily,
      ),
      bodyMedium: TextStyle(
        color: colorData.darkPrimary.withValues(alpha: 0.87),
        fontSize: 14,
        fontFamily: selectedFontFamily,
      ),
      bodySmall: TextStyle(
        color: colorData.darkPrimary.withValues(alpha: 0.6),
        fontSize: 12,
        fontFamily: selectedFontFamily,
      ),
      titleLarge: TextStyle(
        color: colorData.darkPrimary,
        fontWeight: FontWeight.bold,
        fontFamily: selectedFontFamily,
      ),
      headlineSmall: TextStyle(
        color: colorData.darkPrimary,
        fontWeight: FontWeight.bold,
        fontFamily: selectedFontFamily,
      ),
      titleMedium: TextStyle(
        color: colorData.darkPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: selectedFontFamily,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorData.darkPrimary,
        foregroundColor: colorData.darkSecondary,
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: selectedFontFamily,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorData.darkPrimary,
        backgroundColor: Colors.transparent,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: selectedFontFamily,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorData.darkPrimary,
        backgroundColor: Colors.transparent,
        side: BorderSide(color: colorData.darkPrimary, width: 1.5),
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: selectedFontFamily,
        ),
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
        fontFamily: selectedFontFamily,
      ),
      contentTextStyle: TextStyle(
        color: colorData.darkPrimary.withValues(alpha: 0.87),
        fontSize: 16,
        fontFamily: selectedFontFamily,
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
