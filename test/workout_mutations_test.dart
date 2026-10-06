import 'package:flutter_test/flutter_test.dart';

import 'package:plus_one/models/exercise.dart';
import 'package:plus_one/models/workout.dart';
import 'package:plus_one/providers/workout_provider.dart';

void main() {
  final today = DateTime(2026, 10, 6);

  WorkoutProvider build() => WorkoutProvider(today: today);

  WorkoutProvider buildEmpty() =>
      WorkoutProvider(today: today, workouts: const []);

  ExerciseLog logOf(String name, int sets) => ExerciseLog(
    exercise: Exercise(
      name: name,
      equipment: 'Barbell',
      muscleGroups: const ['Chest'],
    ),
    sets: [
      for (var i = 0; i < sets; i++)
        WorkoutSet(reps: 8, weightKg: 60, completed: i.isEven),
    ],
  );

  group('sets', () {
    test('addSet appends a set to the chosen exercise only', () {
      final provider = build();
      final plan = provider.focusWorkout!;
      final before = plan.logs[0].totalSets;

      expect(provider.addSet(plan.id, 0, reps: 10, weightKg: 70), isTrue);

      final updated = provider.byId(plan.id)!;
      expect(updated.logs[0].totalSets, before + 1);
      expect(updated.logs[1], plan.logs[1]);
      expect(updated.logs[0].sets.last.reps, 10);
      // A brand new set starts unchecked so progress does not jump.
      expect(updated.logs[0].sets.last.completed, isFalse);
    });

    test('addSet rejects an unknown exercise index', () {
      final provider = build();
      final plan = provider.focusWorkout!;

      expect(provider.addSet(plan.id, 99), isFalse);
      expect(provider.addSet('missing', 0), isFalse);
      expect(provider.byId(plan.id), plan);
    });

    test('removeSet drops one set', () {
      final provider = build();
      final plan = provider.focusWorkout!;
      final before = plan.logs[0].totalSets;

      expect(provider.removeSet(plan.id, 0, 0), isTrue);
      expect(provider.byId(plan.id)!.logs[0].totalSets, before - 1);
    });

    test('removeSet refuses to empty an exercise', () {
      final provider = buildEmpty();
      provider.addWorkout(
        Workout(
          id: 'solo',
          title: 'Single Set',
          date: today,
          status: WorkoutStatus.planned,
          durationMin: 10,
          estimatedKcal: 50,
          targetMuscleGroups: const ['Core'],
          equipment: const [],
          logs: [logOf('Hanging Leg Raise', 1)],
        ),
      );

      expect(provider.removeSet('solo', 0, 0), isFalse);
      expect(provider.byId('solo')!.logs[0].totalSets, 1);
    });
  });

  group('exercises', () {
    test('addExercise appends to the session and moves the set total', () {
      final provider = build();
      final plan = provider.focusWorkout!;
      final before = plan.totalSets;

      expect(provider.addExercise(plan.id, logOf('Face Pull', 2)), isTrue);

      final updated = provider.byId(plan.id)!;
      expect(updated.logs, hasLength(plan.logs.length + 1));
      expect(updated.totalSets, before + 2);
      expect(updated.logs.last.exercise.name, 'Face Pull');
    });

    test('removeExercise drops the chosen exercise', () {
      final provider = build();
      final plan = provider.focusWorkout!;
      final removed = plan.logs.first.exercise.name;

      expect(provider.removeExercise(plan.id, 0), isTrue);
      expect(provider.byId(plan.id)!.logs.first.exercise.name, isNot(removed));
    });

    test('removeExercise will not delete the last remaining exercise', () {
      final provider = buildEmpty();
      provider.addWorkout(
        Workout(
          id: 'solo',
          title: 'Single Exercise',
          date: today,
          status: WorkoutStatus.planned,
          durationMin: 10,
          estimatedKcal: 50,
          targetMuscleGroups: const ['Core'],
          equipment: const [],
          logs: [logOf('Plank', 2)],
        ),
      );

      expect(provider.removeExercise('solo', 0), isFalse);
      expect(provider.byId('solo')!.logs, hasLength(1));
    });

    test('mutations on a missing workout report failure', () {
      final provider = build();

      expect(provider.addExercise('ghost', logOf('Row', 1)), isFalse);
      expect(provider.removeExercise('ghost', 0), isFalse);
      // Returns void: a no-op rather than a throw is the contract here.
      provider.completeWorkout('ghost');
      provider.reopenWorkout('ghost');
    });
  });

  group('session lifecycle', () {
    test('completeWorkout ticks every set and closes the session', () {
      final provider = build();
      final plan = provider.focusWorkout!;

      provider.completeWorkout(plan.id);

      final done = provider.byId(plan.id)!;
      expect(done.isDone, isTrue);
      expect(done.status, WorkoutStatus.completed);
      expect(done.progress, 1.0);
      expect(done.setsRemaining, 0);
    });

    test('reopenWorkout clears the ticks so it is not instantly complete', () {
      final provider = build();
      final plan = provider.focusWorkout!;
      provider.completeWorkout(plan.id);

      provider.reopenWorkout(plan.id);

      final reopened = provider.byId(plan.id)!;
      expect(reopened.status, WorkoutStatus.planned);
      expect(reopened.completedSets, 0);
      expect(reopened.isDone, isFalse);
    });

    test('completing a session counts toward the month', () {
      final provider = build();
      final plan = provider.focusWorkout!;
      final completedBefore = provider.completedThisMonth;

      provider.completeWorkout(plan.id);

      expect(provider.completedThisMonth, completedBefore + 1);
      // Today now has a finished session, so the run extends by one.
      expect(provider.streakDays, 4);
    });
  });

  group('targets', () {
    test('updateMetricTarget changes the goal but not the reading', () {
      final provider = build();
      final before = provider.metricById('calories')!;

      expect(provider.updateMetricTarget('calories', 900), isTrue);

      final after = provider.metricById('calories')!;
      expect(after.target, 900);
      expect(after.value, before.value);
    });

    test('updateMetricTarget reports an unknown metric', () {
      expect(build().updateMetricTarget('nope', 10), isFalse);
    });
  });
}
