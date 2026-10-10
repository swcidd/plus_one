import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:plus_one/main.dart';
import 'package:plus_one/theme/app_colors.dart';
import 'package:plus_one/theme/app_theme.dart';
import 'package:plus_one/widgets/workout_card.dart';

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

    // The screen leads with the session of the day, so its heading and the
    // action that opens it are both above the fold on first paint.
    expect(find.text('UP NEXT'), findsOneWidget);
    expect(find.textContaining('Upper Body'), findsOneWidget);
    expect(find.text('Resume workout'), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
    expect(
      app.theme?.colorScheme.primary,
      AppTheme.light().colorScheme.primary,
    );
    expect(app.darkTheme?.colorScheme.brightness, Brightness.dark);
  });

  testWidgets('weekly summary and recent sessions sit below the session card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlusOneApp());
    await tester.pumpAndSettle();

    final week = find.text('THIS WEEK');
    await tester.scrollUntilVisible(week, 200);
    expect(week, findsOneWidget);

    // Sessions are shown against the goal rather than as raw totals, which is
    // the whole point of the weekly tile.
    expect(find.text('SESSIONS'), findsOneWidget);
    expect(find.text('DAY STREAK'), findsOneWidget);

    final recent = find.text('RECENT SESSIONS');
    await tester.scrollUntilVisible(recent, 200);
    expect(recent, findsOneWidget);
  });

  testWidgets('the dashboard is the only declared route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlusOneApp());
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.routes?.keys, ['/']);

    // No tab bar yet: the other screens are built next, and a tab bar with one
    // destination would be a control that presents a choice it cannot honour.
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('the workout card opens the detail screen by path', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlusOneApp());
    await tester.pumpAndSettle();

    final recent = find.text('RECENT SESSIONS');
    await tester.scrollUntilVisible(recent, 200);

    // Pushes `/workout/<id>` rather than the bare route name, so the id
    // travels in the path and the resulting link is shareable.
    await tester.tap(find.byType(WorkoutCard).first);
    await tester.pumpAndSettle();

    expect(find.text('Workout Detail'), findsOneWidget);
  });

  testWidgets('the dashboard no longer leads with general health metrics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlusOneApp());
    await tester.pumpAndSettle();

    // Heart rate, steps, sleep and calories belong to a general fitness app.
    // +1 tracks strength training, so their absence is the point: it is what
    // separates this from every other dashboard wearing the same layout.
    for (final removed in [
      'HEART RATE',
      'CALORIES',
      'STEPS',
      'SLEEP SCORE',
      'HYDRATION',
      'DAILY GOALS',
      "TODAY'S VITALS",
      'DAILY COMPLIANCE',
    ]) {
      expect(find.text(removed), findsNothing, reason: '$removed was removed');
    }
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
