import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:plus_one/main.dart';
import 'package:plus_one/theme/app_colors.dart';
import 'package:plus_one/theme/app_theme.dart';

void main() {
  setUpAll(() {
    // Tests run offline; letting google_fonts hit the network makes them
    // flaky and slow. The platform font is enough to assert layout.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders the dashboard shell with the Deep Blue Sea theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlusOneApp());
    await tester.pumpAndSettle();

    expect(find.text('Plus One'), findsOneWidget);
    expect(find.text('Workout Tracker'), findsOneWidget);
    expect(find.text("TODAY'S PLAN"), findsOneWidget);
    expect(find.textContaining('Alex'), findsOneWidget);
    expect(find.text('Resume Workout Session'), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
    expect(
      app.theme?.colorScheme.primary,
      AppTheme.light().colorScheme.primary,
    );
    expect(app.darkTheme?.colorScheme.brightness, Brightness.dark);
  });

  testWidgets('dashboard metrics are reachable further down the list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlusOneApp());
    await tester.pumpAndSettle();

    final goals = find.text("DAILY GOALS");
    await tester.scrollUntilVisible(goals, 200);
    expect(goals, findsOneWidget);

    await tester.scrollUntilVisible(find.text('HEART RATE'), 200);
    expect(find.text('CALORIES'), findsOneWidget);
    expect(find.text('HEART RATE'), findsOneWidget);
  });

  test('light scheme lands on the palette, not an approximation', () {
    final scheme = AppTheme.colorScheme(Brightness.light);

    expect(scheme.brightness, Brightness.light);
    expect(scheme.primary, AppColors.regalNavy);
    expect(scheme.surface, AppColors.mintCream);
    expect(scheme.onSurface, AppColors.prussianBlue);
    expect(scheme.secondary, AppColors.powderBlue);
  });

  test('dark scheme mirrors the palette off the Prussian Blue page', () {
    final scheme = AppTheme.colorScheme(Brightness.dark);

    expect(scheme.brightness, Brightness.dark);
    expect(scheme.surface, AppColors.prussianBlue);
    expect(scheme.onSurface, AppColors.mintCream);
    expect(scheme.primary, AppColors.mintCream);
    expect(scheme.onPrimary, AppColors.prussianBlue);
  });

  test('every text pair in both modes clears WCAG AA', () {
    for (final brightness in Brightness.values) {
      final scheme = AppTheme.colorScheme(brightness);

      final pairs = <String, (Color, Color, double)>{
        'body text': (scheme.onSurface, scheme.surface, 7),
        'secondary text': (scheme.onSurfaceVariant, scheme.surface, 4.5),
        'filled control': (scheme.onPrimary, scheme.primary, 4.5),
        'container text': (
          scheme.onSecondaryContainer,
          scheme.secondaryContainer,
          4.5,
        ),
        'inverse surface': (
          scheme.onInverseSurface,
          scheme.inverseSurface,
          4.5,
        ),
      };

      pairs.forEach((label, pair) {
        final (foreground, background, minimum) = pair;
        expect(
          contrast(foreground, background),
          greaterThanOrEqualTo(minimum),
          reason:
              '$label in $brightness mode: '
              '${foreground.toHex()} on ${background.toHex()}',
        );
      });
    }
  });
}

/// WCAG 2.x contrast ratio between two opaque colors.
double contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  final lighter = a > b ? a : b;
  final darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

extension on Color {
  String toHex() => '#${toARGB32().toRadixString(16).padLeft(8, '0')}';
}
