import 'package:factor/cofig/factor_colors.dart';
import 'package:factor/cofig/factor_strings.dart';
import 'package:flutter/material.dart';

class FactorTheme {
  const FactorTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: const Color(0xFFF4F6F9),
        foregroundColor: FactorColorsDark.kMidnight,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: _textTheme(base.textTheme),
      colorScheme: base.colorScheme.copyWith(
        primary: FactorColorsDark.kSunsetOrange,
        secondary: FactorColorsDark.kEmeraldTeal,
        surface: Colors.white,
        onSurface: FactorColorsDark.kMidnight,
      ),
      cardColor: Colors.white,
      dividerColor: FactorColorsDark.kLightGray.withValues(alpha: 0.1),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: FactorColorsDark.kLightGray.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FactorColorsDark.kSunsetOrange),
        ),
      ),
      iconTheme: base.iconTheme.copyWith(color: FactorColorsDark.kSunsetOrange),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FactorColorsDark.kMidnight,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: FactorColorsDark.kMidnight,
        foregroundColor: FactorColorsDark.kSoftWhite,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: _textTheme(base.textTheme, isDark: true),
      colorScheme: base.colorScheme.copyWith(
        primary: FactorColorsDark.kSunsetOrange,
        secondary: FactorColorsDark.kEmeraldTeal,
        surface: FactorColorsDark.kGunmetal,
        onSurface: FactorColorsDark.kSoftWhite,
      ),
      cardColor: FactorColorsDark.kGunmetal,
      dividerColor: FactorColorsDark.kLightGray.withValues(alpha: 0.2),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: FactorColorsDark.kGunmetal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: FactorColorsDark.kLightGray.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FactorColorsDark.kSunsetOrange),
        ),
      ),
      iconTheme: base.iconTheme.copyWith(color: FactorColorsDark.kSunsetOrange),
    );
  }

  static TextTheme _textTheme(TextTheme base, {bool isDark = false}) {
    final color = isDark
        ? FactorColorsDark.kSoftWhite
        : FactorColorsDark.kMidnight;
    return base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(color: color),
          displayMedium: base.displayMedium?.copyWith(color: color),
          displaySmall: base.displaySmall?.copyWith(color: color),
          headlineMedium: base.headlineMedium?.copyWith(color: color),
          headlineSmall: base.headlineSmall?.copyWith(color: color),
          titleLarge: base.titleLarge?.copyWith(color: color),
          bodyLarge: base.bodyLarge?.copyWith(color: color),
          bodyMedium: base.bodyMedium?.copyWith(color: color),
          bodySmall: base.bodySmall?.copyWith(color: color),
          labelLarge: base.labelLarge?.copyWith(color: color),
        )
        .apply(fontFamily: FactorStrings.bungee);
  }
}
