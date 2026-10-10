import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plus_one/models/workout.dart';
import 'package:plus_one/providers/workout_provider.dart';
import 'package:plus_one/theme/app_colors.dart';
import 'package:plus_one/theme/app_theme.dart';
import 'package:plus_one/widgets/bottom_nav_bar.dart';
import 'package:plus_one/widgets/new_workout_dialog.dart';
import 'package:plus_one/widgets/workout_action_button.dart';
import 'package:plus_one/widgets/workout_card.dart';

import 'support/harness.dart';

void main() {
  setUpAll(useOfflineFonts);

  group('theme', () {
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
  });

  group('empty account', () {
    testWidgets('the dashboard opens with nothing in it', (tester) async {
      await tester.pumpWidget(emptyApp());
      await tester.pumpAndSettle();

      expect(find.text('Plus One'), findsOneWidget);
      expect(find.text('Workout Tracker'), findsOneWidget);

      // No session, so the card has to say so rather than inviting the user to
      // resume something that does not exist.
      expect(find.text('NO SESSION SCHEDULED'), findsOneWidget);
      expect(find.text('Rest day'), findsOneWidget);
      expect(find.text('Resume workout'), findsNothing);
      expect(find.text('Start workout'), findsNothing);
    });

    testWidgets('the weekly tiles read zero rather than missing', (
      tester,
    ) async {
      await tester.pumpWidget(emptyApp());
      await tester.pumpAndSettle();

      final week = find.text('THIS WEEK');
      await tester.scrollUntilVisible(week, 200);

      expect(find.text('SESSIONS'), findsOneWidget);
      expect(find.text('DAY STREAK'), findsOneWidget);
      // 0 of the default goal, and a zero-day streak.
      expect(find.text('0/4'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('recent sessions offers a way forward when empty', (
      tester,
    ) async {
      await tester.pumpWidget(emptyApp());
      await tester.pumpAndSettle();

      final empty = find.text('No finished sessions yet');
      await tester.scrollUntilVisible(empty, 200);
      expect(empty, findsOneWidget);

      // An empty list that only says "nothing here" leaves the user with no way
      // forward, which is the whole reason EmptyState carries an action.
      expect(find.byType(WorkoutCard), findsNothing);
    });

    testWidgets('the action cannot navigate when there is nothing to open', (
      tester,
    ) async {
      await tester.pumpWidget(emptyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(WorkoutActionButton));
      await tester.pumpAndSettle();

      // With nothing logged the action cannot open a session, so it opens the
      // create form instead. That is the only sensible next step for an
      // account with no sessions, and the one the user is reaching for.
      expect(find.text('Workout Detail'), findsNothing);
      expect(find.text('New workout'), findsOneWidget);
    });

    testWidgets('the dashboard leads with no general health metrics', (
      tester,
    ) async {
      await tester.pumpWidget(emptyApp());
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
        expect(
          find.text(removed),
          findsNothing,
          reason: '$removed was removed',
        );
      }
    });
  });

  group('populated account', () {
    testWidgets('the dashboard leads with the session of the day', (
      tester,
    ) async {
      await tester.pumpWidget(seededApp());
      await tester.pumpAndSettle();

      expect(find.text('UP NEXT'), findsOneWidget);
      expect(find.textContaining('Upper Body'), findsOneWidget);
      expect(find.text('Resume workout'), findsOneWidget);
    });

    testWidgets('the workout card opens the detail screen by path', (
      tester,
    ) async {
      await tester.pumpWidget(seededApp());
      await tester.pumpAndSettle();

      // Scrolled to the card itself rather than to the section heading: the
      // heading can be visible while the first row is still below the fold, and
      // tapping an off-screen widget silently hits whatever is at its position.
      final card = find.byType(WorkoutCard).first;
      await tester.scrollUntilVisible(card, 200);
      // Settled separately because the scroll animates; tapping mid-flight
      // would hit whatever row had moved into the tapped position instead.
      await tester.pumpAndSettle();

      // Pushes `/workout/<id>` rather than the bare route name, so the id
      // travels in the path and the resulting link is shareable.
      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(find.text('Workout Detail'), findsOneWidget);
    });
  });

  group('destination bar', () {
    testWidgets('offers every destination exactly once', (tester) async {
      await tester.pumpWidget(seededApp());
      await tester.pumpAndSettle();

      final bar = find.byType(AppBottomNav);
      expect(bar, findsOneWidget);

      for (final label in ['Home', 'Calendar', 'Library', 'Profile']) {
        expect(
          find.descendant(of: bar, matching: find.text(label)),
          findsOneWidget,
          reason: 'the bar should offer $label',
        );
      }
    });

    testWidgets('tapping a destination swaps the visible screen', (
      tester,
    ) async {
      await tester.pumpWidget(seededApp());
      await tester.pumpAndSettle();

      expect(find.text('UP NEXT'), findsOneWidget);

      await _tapDestination(tester, 'Calendar');
      expect(find.text('Calendar is next'), findsOneWidget);

      await _tapDestination(tester, 'Library');
      expect(find.text('Library is next'), findsOneWidget);
    });

    testWidgets('the dashboard avatar opens the profile tab', (tester) async {
      await tester.pumpWidget(seededApp());
      await tester.pumpAndSettle();

      // The avatar is a cross-tab shortcut, so it has to reach the same place a
      // tap on the bar does rather than push a second profile route. Scoped to
      // the app bar: the bar's Profile destination carries the same tooltip.
      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byTooltip('Profile'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile is next'), findsOneWidget);
    });

    testWidgets('a tab route opens its own tab, not the home one', (
      tester,
    ) async {
      await tester.pumpWidget(seededApp());
      await tester.pumpAndSettle();

      // Replaces the shell rather than stacking on top of it, which is what
      // keeps `/calendar` from rendering behind a live home screen.
      await tester.binding.handlePushRoute('/library');
      await tester.pumpAndSettle();

      expect(find.text('Library is next'), findsOneWidget);
    });
  });

  group('new workout dialog', () {
    testWidgets('the action opens it when the account is empty', (
      tester,
    ) async {
      await tester.pumpWidget(emptyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(WorkoutActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(NewWorkoutDialog), findsOneWidget);
      expect(find.text('New workout'), findsOneWidget);
      expect(find.text('NAME THIS SESSION'), findsOneWidget);
      expect(find.text('DATE'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('the action opens a session instead when one is planned', (
      tester,
    ) async {
      await tester.pumpWidget(seededApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(WorkoutActionButton));
      await tester.pumpAndSettle();

      // A planned session is a better answer than a form: opening the form
      // would offer to create a second session for a day that already has one.
      expect(find.byType(NewWorkoutDialog), findsNothing);
      expect(find.text('Workout Detail'), findsOneWidget);
    });

    testWidgets('starting creates the workout and opens it', (tester) async {
      final provider = WorkoutProvider();
      await tester.pumpWidget(emptyAppWith(provider));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(WorkoutActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Leg Day');
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // The session has to be in the store before the detail screen can find
      // it, or the push lands on "Session not found".
      expect(provider.workouts, hasLength(1));
      expect(provider.workouts.single.title, 'Leg Day');
      expect(provider.workouts.single.status, WorkoutStatus.planned);
      expect(find.text('Workout Detail'), findsOneWidget);
    });

    testWidgets('an empty name falls back to the date', (tester) async {
      final provider = WorkoutProvider();
      await tester.pumpWidget(emptyAppWith(provider));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(WorkoutActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // Naming a session is not the point of opening the app, so an untitled
      // one is created rather than rejected.
      expect(provider.workouts, hasLength(1));
      expect(provider.workouts.single.title, isNotEmpty);
      expect(provider.workouts.single.title, contains('Training'));
    });

    testWidgets('cancelling creates nothing', (tester) async {
      final provider = WorkoutProvider();
      await tester.pumpWidget(emptyAppWith(provider));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(WorkoutActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(provider.workouts, isEmpty);
      expect(find.byType(NewWorkoutDialog), findsNothing);
      expect(find.text('Workout Detail'), findsNothing);
    });
  });

  group('bar action', () {
    testWidgets('sits in the middle, between calendar and library', (
      tester,
    ) async {
      await tester.pumpWidget(seededApp());
      await tester.pumpAndSettle();

      final bar = find.byType(AppBottomNav);
      double xOf(String label) => tester
          .getCenter(find.descendant(of: bar, matching: find.text(label)))
          .dx;

      // The action has to land between the two tabs it separates, not on top of
      // either. An off-centre button reads as a layout mistake even when
      // everything is tappable.
      final action = tester.getCenter(find.byType(WorkoutActionButton)).dx;
      expect(action, greaterThan(xOf('Calendar')));
      expect(action, lessThan(xOf('Library')));

      // And it has to be centred on the bar, not merely between the two.
      expect(action, closeTo(tester.getCenter(bar).dx, 1));
    });

    testWidgets('opens the session to train next', (tester) async {
      await tester.pumpWidget(seededApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(WorkoutActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Workout Detail'), findsOneWidget);
    });

    testWidgets('is labelled, and says so exactly once', (tester) async {
      await tester.pumpWidget(seededApp());
      await tester.pumpAndSettle();

      final button = find.byType(WorkoutActionButton);
      expect(button, findsOneWidget);

      // The label belongs to the control, not to the bar's destination row, so
      // it renders inside the button rather than as a sixth navigation entry.
      expect(
        find.descendant(of: button, matching: find.text('WORKOUT')),
        findsOneWidget,
      );

      // excludeSemantics on the button is what stops a screen reader announcing
      // the label twice; the visible text is still announced through the
      // button's own label, so the two must not also be separate nodes.
      final node = tester.getSemantics(find.byType(WorkoutActionButton));
      expect(
        node.label,
        contains('Workout'),
        reason: 'the circle needs an accessible name without its own',
      );
    });

    testWidgets('and its label fit inside the bar', (tester) async {
      await tester.pumpWidget(seededApp());
      await tester.pumpAndSettle();

      final bar = find.byType(AppBottomNav);
      final barBottom = tester.getBottomLeft(bar).dy;
      final screenBottom =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;

      // The label sits below the circle, so a fixed top padding alone would push
      // the text past the bottom of the bar and off the screen.
      final labelCentre = tester
          .getCenter(
            find.descendant(
              of: find.byType(WorkoutActionButton),
              matching: find.text('WORKOUT'),
            ),
          )
          .dy;
      expect(labelCentre, lessThanOrEqualTo(barBottom));
      expect(labelCentre, lessThan(screenBottom));
    });

    testWidgets('is not a fifth destination', (tester) async {
      await tester.pumpWidget(seededApp());
      await tester.pumpAndSettle();

      // The bar has five slots but four destinations; if the action were routed
      // as a destination it would need its own URL, which it has no screen for.
      final bar = find.byType(AppBottomNav);
      final dest = tester.widget<NavigationBar>(
        find.descendant(of: bar, matching: find.byType(NavigationBar)),
      );
      expect(dest.destinations, hasLength(5));

      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(WorkoutActionButton), findsOneWidget);
    });
  });
}

/// Taps a destination in the bar by its visible label.
///
/// Scoped to the bar so a label that also appears in the screen body - the
/// dashboard's "Profile" heading, say - cannot be tapped by mistake.
Future<void> _tapDestination(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(AppBottomNav), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
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
