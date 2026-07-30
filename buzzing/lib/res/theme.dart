import 'package:flutter/material.dart';

class BuzzingTheme extends ThemeExtension<BuzzingTheme> {
  final Color success;
  final Color warning;
  final Color link;
  final Color headerBg;
  final Color navBarBg;
  final Color mentionBg;
  final Color stickerBg;
  final Color online;

  const BuzzingTheme({
    required this.success,
    required this.warning,
    required this.link,
    required this.headerBg,
    required this.navBarBg,
    required this.mentionBg,
    required this.stickerBg,
    required this.online,
  });

  static const light = BuzzingTheme(
    success: Color(0xFF10CC64),
    warning: Color(0xFFFFC563),
    link: Color(0xFF3370FF),
    headerBg: Color(0xFFD8DFF5),
    navBarBg: Color(0xFFD8DFF5),
    mentionBg: Color(0xFFE8F2FF),
    stickerBg: Color(0xFFFDFEFF),
    online: Color(0xFF10CC64),
  );

  static const dark = BuzzingTheme(
    success: Color(0xFF10CC64),
    warning: Color(0xFFFFC563),
    link: Color(0xFF5496EB),
    headerBg: Color(0xFF1A1C1E),
    navBarBg: Color(0xFF1A1C1E),
    mentionBg: Color(0xFF1B3A5C),
    stickerBg: Color(0xFF2C2C2C),
    online: Color(0xFF10CC64),
  );

  @override
  BuzzingTheme copyWith({
    Color? success,
    Color? warning,
    Color? link,
    Color? headerBg,
    Color? navBarBg,
    Color? mentionBg,
    Color? stickerBg,
    Color? online,
  }) {
    return BuzzingTheme(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      link: link ?? this.link,
      headerBg: headerBg ?? this.headerBg,
      navBarBg: navBarBg ?? this.navBarBg,
      mentionBg: mentionBg ?? this.mentionBg,
      stickerBg: stickerBg ?? this.stickerBg,
      online: online ?? this.online,
    );
  }

  @override
  BuzzingTheme lerp(ThemeExtension<BuzzingTheme>? other, double t) {
    if (other is! BuzzingTheme) return this;
    return BuzzingTheme(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      link: Color.lerp(link, other.link, t)!,
      headerBg: Color.lerp(headerBg, other.headerBg, t)!,
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
      mentionBg: Color.lerp(mentionBg, other.mentionBg, t)!,
      stickerBg: Color.lerp(stickerBg, other.stickerBg, t)!,
      online: Color.lerp(online, other.online, t)!,
    );
  }
}

class AppTheme {
  static const _seedColor = Color(0xFF3370FF);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: _textTheme(scheme),
      appBarTheme: AppBarTheme(
        backgroundColor: BuzzingTheme.light.headerBg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      extensions: [BuzzingTheme.light],
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: _textTheme(scheme),
      appBarTheme: AppBarTheme(
        backgroundColor: BuzzingTheme.dark.headerBg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      extensions: [BuzzingTheme.dark],
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: scheme.primary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
