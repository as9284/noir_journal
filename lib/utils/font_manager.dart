import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FontManager {
  static const Map<AppFontFamily, String> _localFontFamilies = {
    AppFontFamily.inter: 'Inter',
    AppFontFamily.roboto: 'Roboto',
    AppFontFamily.opensans: 'OpenSans',
    AppFontFamily.lato: 'Lato',
    AppFontFamily.sourcesans: 'SourceSans3',
    AppFontFamily.nunito: 'Nunito',
  };

  static const Map<AppFontFamily, String> _systemFallbacks = {
    AppFontFamily.inter: 'sans-serif',
    AppFontFamily.roboto: 'sans-serif',
    AppFontFamily.opensans: 'sans-serif',
    AppFontFamily.lato: 'sans-serif',
    AppFontFamily.sourcesans: 'sans-serif',
    AppFontFamily.nunito: 'sans-serif',
  };

  /// Get a TextStyle with the specified font family using local fonts
  static TextStyle getTextStyle({
    required AppFontFamily fontFamily,
    TextStyle? baseStyle,
  }) {
    final localFontFamily = _localFontFamilies[fontFamily];

    return (baseStyle ?? const TextStyle()).copyWith(
      fontFamily: localFontFamily,
    );
  }

  /// Get font family string for local fonts
  static String? getFontFamily(AppFontFamily fontFamily) {
    return _localFontFamilies[fontFamily] ?? _systemFallbacks[fontFamily];
  }

  /// No need to pre-cache fonts since they're bundled locally
  static Future<void> precacheFonts() async {
    // Local fonts are automatically available, no pre-caching needed
    debugPrint('Using local bundled fonts - no pre-caching required');
  }
}
