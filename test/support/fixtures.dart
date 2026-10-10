import 'package:plus_one/models/profile_stats.dart';
import 'package:plus_one/providers/workout_provider.dart';

import 'seed_data.dart';

/// A provider holding the seeded sessions, for tests that need content.
///
/// The application ships no sample data, so every test that asserts on a
/// non-empty screen has to say what it is putting there. Keeping that in one
/// helper means a test never silently depends on a default it cannot see, and
/// deleting a fixture from [seedData] fails loudly here rather than as a
/// confusing null error somewhere inside a widget test.
WorkoutProvider seededProvider({DateTime? today}) => WorkoutProvider(
  today: today ?? DateTime.now(),
  workouts: seedWorkouts(today ?? DateTime.now()),
  metrics: seedMetrics(),
  profile: seedProfile(),
);

/// The same sessions with today's plan already finished, for tests that need
/// a completed day behind them.
WorkoutProvider seededProviderWithPlanFinished({DateTime? today}) {
  final provider = seededProvider(today: today);
  final plan = provider.focusWorkout;
  if (plan == null) return provider;

  provider.updateWorkout(
    plan.copyWith(
      logs: [
        for (final log in plan.logs)
          log.copyWith(
            sets: [for (final set in log.sets) set.copyWith(completed: true)],
          ),
      ],
      status: plan.status,
    ),
  );
  return provider;
}

/// A profile with the seeded records and badges.
ProfileStats seededProfileStats() => seedProfile();
