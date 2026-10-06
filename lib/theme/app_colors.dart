import 'package:flutter/material.dart';

/// Deep Blue Sea palette.
///
/// Regal Navy carries every filled control, Prussian Blue anchors body text,
/// Powder Blue handles borders and muted surfaces, and Mint Cream is the
/// page. That split is what stops a five-colour palette from turning into
/// blue soup: exactly one hue does the work of an action, and the rest is
/// tint, text or canvas.
///
/// https://coolors.co/134074-13315c-0b2545-8da9c4-eef4ed
abstract final class AppColors {
  // --- Palette --------------------------------------------------------------
  static const Color regalNavy = Color(0xFF134074);
  static const Color oxfordNavy = Color(0xFF13315C);
  static const Color prussianBlue = Color(0xFF0B2545);
  static const Color powderBlue = Color(0xFF8DA9C4);
  static const Color mintCream = Color(0xFFEEF4ED);

  // --- Derived neutrals -----------------------------------------------------
  // A five-colour palette has no greys, so every surface step, divider and
  // secondary label below is interpolated between two palette colours rather
  // than pulled off a grey ramp. Interpolation keeps the hue locked to the
  // brand; a neutral grey would introduce a second, unrelated colour cast.

  /// Secondary label on the light canvas. Powder Blue mixed toward Oxford
  /// Navy until it clears 4.5:1 against Mint Cream.
  static const Color lightOnSurfaceVariant = Color(0xFF4E6E92);

  /// Borders and outlined controls. A step darker so a button edge is
  /// unmistakably an edge rather than a hint.
  static const Color lightOutline = Color(0xFF405D82);

  /// Card borders and dividers. Deliberately faint: cards already separate
  /// by fill, so a loud outline would double-draw every boundary.
  static const Color lightOutlineVariant = Color(0xFFC7D6DD);

  /// Light surface ramp, tinted from Mint Cream toward white so cards read as
  /// lifted off the canvas instead of cut out of it.
  static const Color lightSurfaceLowest = Color(0xFFF9FCF9);
  static const Color lightSurfaceLow = Color(0xFFF1F6F3);
  static const Color lightSurface = Color(0xFFE9F0EE);
  static const Color lightSurfaceHigh = Color(0xFFE1E9EA);
  static const Color lightSurfaceHighest = Color(0xFFD9E2E6);

  /// Dark mode secondary label: Powder Blue on Prussian Blue lands at 6.3:1.
  static const Color darkOnSurfaceVariant = powderBlue;

  static const Color darkOutline = powderBlue;
  static const Color darkOutlineVariant = Color(0xFF2E4A75);

  /// Dark surface ramp, tinted up from Prussian Blue. The top step lands on
  /// Regal Navy, which ties the raised surfaces back to the palette.
  static const Color darkSurfaceLowest = Color(0xFF0F2A4E);
  static const Color darkSurfaceLow = Color(0xFF132F57);
  static const Color darkSurface = Color(0xFF17345F);
  static const Color darkSurfaceHigh = Color(0xFF1B3A6A);
  static const Color darkSurfaceHighest = Color(0xFF204174);

  /// A lifted navy used where dark mode needs a container that separates
  /// from the Prussian Blue page without going pale.
  static const Color darkContainer = Color(0xFF204174);

  static const Color darkInverseSurface = Color(0xFFDCE7F1);
  static const Color darkInverseOnSurface = prussianBlue;

  // --- Error ----------------------------------------------------------------
  // Kept on the standard Material scale rather than recoloured. Red for
  // destructive is a learned convention, and rehuing it to fit the palette
  // would make "delete" less obvious, not prettier.
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
