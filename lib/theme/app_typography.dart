import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale from the Stitch wireframes.
///
/// Sizes are the spec's base sizes; `height` is the spec's line box divided
/// by the font size, and `letterSpacing` is the spec's em value multiplied
/// out to logical pixels so it stays correct at the default text scale.
abstract final class AppTypography {
  static TextStyle _sansStyle({
    required double fontSize,
    required double height,
    required double letterSpacing,
    required FontWeight fontWeight,
    Color? color,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      height: height,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle _monoStyle({
    required double fontSize,
    required double height,
    required double letterSpacing,
    required FontWeight fontWeight,
    Color? color,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      height: height,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Builds the full text theme for a color scheme.
  ///
  /// The M3 slots are filled from the wireframe scale so component text
  /// (app bar, navigation labels, buttons) inherits the same rhythm as the
  /// hand-written screen text instead of falling back to Roboto defaults.
  static TextTheme textTheme(ColorScheme scheme) {
    return TextTheme(
      // displayHero: 48/52, -1.92, w700
      displayLarge: _sansStyle(
        fontSize: 48,
        height: 52 / 48,
        letterSpacing: -1.92,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      // headlineXl: 32/38, -0.96, w600
      headlineLarge: _sansStyle(
        fontSize: 32,
        height: 38 / 32,
        letterSpacing: -0.96,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      // headlineLg: 24/30, -0.48, w600
      headlineMedium: _sansStyle(
        fontSize: 24,
        height: 30 / 24,
        letterSpacing: -0.48,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      // headlineMd: 18/24, -0.18, w600
      headlineSmall: _sansStyle(
        fontSize: 18,
        height: 24 / 18,
        letterSpacing: -0.18,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      // bodyLg: 16/24, 0, w400
      titleLarge: _sansStyle(
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      // bodyMd: 14/20, 0, w400
      titleMedium: _sansStyle(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      // bodySm: 13/18, 0.13, w400
      titleSmall: _sansStyle(
        fontSize: 13,
        height: 18 / 13,
        letterSpacing: 0.13,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      bodyLarge: _sansStyle(
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      bodyMedium: _sansStyle(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      bodySmall: _sansStyle(
        fontSize: 13,
        height: 18 / 13,
        letterSpacing: 0.13,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      // Button labels: 14/20, w500.
      labelLarge: _sansStyle(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
        color: scheme.onPrimary,
      ),
      // labelCaps: 11/14, 0.88, w600.
      labelMedium: _sansStyle(
        fontSize: 11,
        height: 14 / 11,
        letterSpacing: 0.88,
        fontWeight: FontWeight.w600,
        color: scheme.onSurfaceVariant,
      ),
      // annotationMono: 10/14, 0.4, w500.
      labelSmall: _monoStyle(
        fontSize: 10,
        height: 14 / 10,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

/// Roles that do not map onto a Material text theme slot.
///
/// Kept off [TextTheme] because Material reserves those slots for its own
/// components; reusing them here would silently restyle every app bar and
/// dialog in the app.
class AppText {
  const AppText._(this._scheme);

  final ColorScheme _scheme;

  static AppText of(ColorScheme scheme) => AppText._(scheme);

  /// dataMetric: 36/40, -1.08, w700. Big single numbers on stat tiles.
  TextStyle get dataMetric => AppTypography._sansStyle(
    fontSize: 36,
    height: 40 / 36,
    letterSpacing: -1.08,
    fontWeight: FontWeight.w700,
    color: _scheme.onSurface,
  );

  /// labelCaps: 11/14, 0.88, w600, uppercase. Section eyebrows.
  TextStyle get labelCaps => AppTypography._sansStyle(
    fontSize: 11,
    height: 14 / 11,
    letterSpacing: 0.88,
    fontWeight: FontWeight.w600,
    color: _scheme.onSurfaceVariant,
  );

  /// annotationMono: 10/14, 0.4, w500. Timestamps and identifiers.
  TextStyle get annotationMono => AppTypography._monoStyle(
    fontSize: 10,
    height: 14 / 10,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w500,
    color: _scheme.onSurfaceVariant,
  );

  /// Compact value used inside rows where [dataMetric] would dominate.
  TextStyle get metric => AppTypography._sansStyle(
    fontSize: 20,
    height: 24 / 20,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w700,
    color: _scheme.onSurface,
  );
}

extension AppTextStyle on BuildContext {
  /// `context.text.dataMetric`
  AppText get text => AppText.of(Theme.of(this).colorScheme);
}
