import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class NotesPalette {
  const NotesPalette._();

  static const Color ink = Color(0xFF0D1C1C);
  static const Color muted = Color(0xFF6B7F8F);
  static const Color canvas = Color(0xFFF7FCFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF0AD9D9);
  static const Color accentDark = Color(0xFF088F8F);
  static const Color noteText = Color(0xFF4A9C9C);
  static const Color border = Color(0xFFCFE8E8);
  static const Color fieldHint = Color(0xFF8FA1B3);
  static const Color avatar = Color(0xFFF2F4F7);
  static const Color facebook = Color(0xFF1877F2);
}

class NotesTheme {
  const NotesTheme._();

  static ThemeData light({required Color accent}) {
    final backgroundColor = _backgroundForAccent(accent);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      surface: NotesPalette.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: NotesPalette.ink,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        headlineSmall: TextStyle(
          color: NotesPalette.ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 1.27,
        ),
        titleLarge: TextStyle(
          color: NotesPalette.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.28,
        ),
        titleMedium: TextStyle(
          color: NotesPalette.ink,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          color: NotesPalette.ink,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: NotesPalette.noteText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          color: NotesPalette.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: NotesPalette.ink,
        centerTitle: false,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NotesPalette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: NotesPalette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: NotesPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  static Color _backgroundForAccent(Color accent) {
    return Color.alphaBlend(accent.withValues(alpha: 0.16), Colors.white);
  }
}
