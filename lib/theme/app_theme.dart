import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Timing and easing shared by every transition in the app.
///
/// Pulled out so screens cannot each invent their own curve. Easings are
/// the strong variants from easing curves rather than the built-in ones,
/// which are too flat to feel deliberate at these durations.
abstract final class AppMotion {
  /// Fast response for presses and toggles.
  static const Duration press = Duration(milliseconds: 160);

  /// Default for state changes inside a screen.
  static const Duration ui = Duration(milliseconds: 200);

  /// Route transitions and sheet entrances.
  static const Duration route = Duration(milliseconds: 250);

  /// Starts fast, settles gently. Entering elements.
  static const Cubic easeOut = Cubic(0.23, 1, 0.32, 1);

  /// Symmetric acceleration. Moving elements.
  static const Cubic easeInOut = Cubic(0.77, 0, 0.175, 1);
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ColorScheme colorScheme(Brightness brightness) {
    return brightness == Brightness.light ? _lightScheme : _darkScheme;
  }

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = colorScheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: AppTypography.textTheme(scheme),
      scaffoldBackgroundColor: isLight
          ? AppColors.lightBackground
          : AppColors.darkBackground,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight
            ? AppColors.lightBackground
            : AppColors.darkBackground,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme(scheme).headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.surfaceContainerHighest,
          disabledForegroundColor: scheme.onSurfaceVariant,
          elevation: 0,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
          textStyle: AppTypography.textTheme(scheme).labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
          textStyle: AppTypography.textTheme(
            scheme,
          ).labelLarge?.copyWith(color: scheme.onSurface),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(44, 44),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
          textStyle: AppTypography.textTheme(
            scheme,
          ).labelLarge?.copyWith(color: scheme.onSurface),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: isLight
            ? AppColors.lightSurfaceHighest
            : AppColors.darkSurfaceHighest,
        height: 68,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.textTheme(scheme).labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
        labelStyle: AppTypography.textTheme(scheme).labelSmall,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs + 4,
          vertical: AppSpacing.xs,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: AppTypography.textTheme(
          scheme,
        ).bodyMedium?.copyWith(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.md),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Exact palette from the wireframes, expressed as a Material color scheme.
  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    // The wireframe value (#858386) lands under 4.5:1 on the container, so
    // the lighter inverse surface is used instead to clear WCAG AA.
    onPrimaryContainer: AppColors.lightInverseOnSurface,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.lightSurfaceHigh,
    onSecondaryContainer: AppColors.lightOnSurface,
    tertiary: AppColors.primary,
    onTertiary: AppColors.onPrimary,
    tertiaryContainer: AppColors.lightSurfaceHighest,
    onTertiaryContainer: AppColors.lightOnSurface,
    error: AppColors.error,
    onError: AppColors.onPrimary,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.lightBackground,
    onSurface: AppColors.lightOnSurface,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    outline: AppColors.lightOutline,
    outlineVariant: AppColors.lightOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppColors.lightInverseSurface,
    onInverseSurface: AppColors.lightInverseOnSurface,
    inversePrimary: Color(0xFFC8C6C8),
    surfaceContainerLowest: AppColors.lightSurfaceLowest,
    surfaceContainerLow: AppColors.lightSurfaceLow,
    surfaceContainer: AppColors.lightSurface,
    surfaceContainerHigh: AppColors.lightSurfaceHigh,
    surfaceContainerHighest: AppColors.lightSurfaceHighest,
  );

  /// Monochrome dark scale: the light scale mirrored, so contrast ratios
  /// between text and surface stay identical across both modes.
  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkInverseSurface,
    onPrimary: AppColors.darkBackground,
    primaryContainer: AppColors.darkOnSurface,
    onPrimaryContainer: AppColors.darkBackground,
    secondary: AppColors.darkOutline,
    onSecondary: AppColors.darkBackground,
    secondaryContainer: AppColors.darkOutlineVariant,
    onSecondaryContainer: AppColors.darkOnSurface,
    tertiary: AppColors.darkInverseSurface,
    onTertiary: AppColors.darkBackground,
    tertiaryContainer: AppColors.darkSurfaceHigh,
    onTertiaryContainer: AppColors.darkOnSurface,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: AppColors.onErrorContainer,
    onErrorContainer: AppColors.errorContainer,
    surface: AppColors.darkBackground,
    onSurface: AppColors.darkOnSurface,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppColors.darkInverseOnSurface,
    onInverseSurface: AppColors.darkInverseSurface,
    inversePrimary: Color(0xFF5F5E60),
    surfaceContainerLowest: AppColors.darkSurfaceLowest,
    surfaceContainerLow: AppColors.darkSurfaceLow,
    surfaceContainer: AppColors.darkSurface,
    surfaceContainerHigh: AppColors.darkSurfaceHigh,
    surfaceContainerHighest: AppColors.darkSurfaceHighest,
  );
}
