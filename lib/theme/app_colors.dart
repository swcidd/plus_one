import 'package:flutter/material.dart';

/// Monochrome palette lifted from the Stitch wireframes.
///
/// The design is intentionally achromatic: black is the only action colour
/// and every surface step is a shade of neutral grey. Keeping the scale in
/// one place stops screens from inventing their own greys, which is how a
/// monochrome UI starts drifting warm in one place and cool in another.
abstract final class AppColors {
  // --- Light -----------------------------------------------------------------
  static const Color lightBackground = Color(0xFFF9F9F9);
  static const Color lightOnSurface = Color(0xFF1A1C1C);
  static const Color lightOnSurfaceVariant = Color(0xFF47464A);
  static const Color lightOutline = Color(0xFF78767B);
  static const Color lightOutlineVariant = Color(0xFFC8C5CA);

  static const Color lightSurfaceLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceLow = Color(0xFFF3F3F3);
  static const Color lightSurface = Color(0xFFEEEEEE);
  static const Color lightSurfaceHigh = Color(0xFFE8E8E8);
  static const Color lightSurfaceHighest = Color(0xFFE2E2E2);

  static const Color lightInverseSurface = Color(0xFF2F3131);
  static const Color lightInverseOnSurface = Color(0xFFF0F1F1);

  // --- Dark ------------------------------------------------------------------
  ///
  /// The dark scale is the light scale mirrored, not a separately designed
  /// palette. That keeps contrast ratios identical in both modes so a metric
  /// card reads the same on a phone at night as it does in daylight.
  static const Color darkBackground = Color(0xFF121313);
  static const Color darkOnSurface = Color(0xFFE4E1E4);
  static const Color darkOnSurfaceVariant = Color(0xFFC8C5CA);
  static const Color darkOutline = Color(0xFF929196);
  static const Color darkOutlineVariant = Color(0xFF47464A);

  static const Color darkSurfaceLowest = Color(0xFF1A1C1C);
  static const Color darkSurfaceLow = Color(0xFF1F2021);
  static const Color darkSurface = Color(0xFF232425);
  static const Color darkSurfaceHigh = Color(0xFF282A2A);
  static const Color darkSurfaceHighest = Color(0xFF2E3030);

  static const Color darkInverseSurface = Color(0xFFF0F1F1);
  static const Color darkInverseOnSurface = Color(0xFF2F3131);

  // --- Shared ----------------------------------------------------------------
  /// Pure black is the action colour in the wireframes, used for filled
  /// buttons and progress bars rather than for large backgrounds.
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1C1B1D);

  static const Color secondary = Color(0xFF5F5E61);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
}

/// Corner radius scale. Mirrors the Tailwind radius tokens in the
/// wireframes so a card is never rounded differently on two screens.
abstract final class AppRadius {
  /// Tags and inline annotations.
  static const double xs = 4;

  /// Buttons and inputs.
  static const double sm = 8;

  /// Cards and panels.
  static const double md = 12;

  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius control = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius tag = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

/// 4pt spacing grid. `gutter` is the screen inset used by every screen.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double gutter = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
