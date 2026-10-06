import 'package:flutter/foundation.dart';

import '../models/metric.dart';
import '../models/profile_stats.dart';
import '../models/workout.dart';
import 'seed_data.dart';

/// Single source of truth for workout state.
///
/// Screens read through getters and mutate through the small verb set below,
/// so there is one place where a change is decided and exactly one
/// `notifyListeners` per change. Nothing here knows about widgets, which
/// keeps the API swap later confined to the constructors.
class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider({
    DateTime? today,
    List<Workout>? workouts,
    List<Metric>? metrics,
    ProfileStats? profile,
  }) : _today = _dayOnly(today ?? DateTime.now()),
       // Copies are deliberate: callers often hand over const or
       // unmodifiable fixtures, and this class has to stay free to reorder
       // and replace entries in place.
       _workouts = List.of(workouts ?? seedWorkouts(today ?? DateTime.now())),
       _metrics = List.of(metrics ?? seedMetrics()),
       _profile = profile ?? seedProfile() {
    _sort();
  }

  final DateTime _today;
  final List<Workout> _workouts;
  final List<Metric> _metrics;
  ProfileStats _profile;
  int _nextId = 0;

  static DateTime _dayOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  // --- Reads -----------------------------------------------------------------

  DateTime get today => _today;

  List<Workout> get workouts => List.unmodifiable(_workouts);

  List<Metric> get metrics => List.unmodifiable(_metrics);

  ProfileStats get profile => _profile;

  /// The session the dashboard should push the user toward: today's plan if
  /// it exists, otherwise the next one on the calendar.
  Workout? get focusWorkout {
    final todayWorkouts = workoutsOn(_today);
    for (final workout in todayWorkouts) {
      if (workout.status == WorkoutStatus.planned) return workout;
    }
    for (final workout in _workouts) {
      if (workout.date.isAfter(_today) &&
          workout.status == WorkoutStatus.planned) {
        return workout;
      }
    }
    return null;
  }

  List<Workout> workoutsOn(DateTime date) {
    final day = _dayOnly(date);
    return _workouts
        .where((workout) => _dayOnly(workout.date) == day)
        .toList(growable: false);
  }

  Workout? byId(String id) {
    for (final workout in _workouts) {
      if (workout.id == id) return workout;
    }
    return null;
  }

  /// Days in a row with at least one finished session, counting back from
  /// today. Today may still be empty, so the count starts from yesterday in
  /// that case rather than reporting a broken streak before the user trains.
  int get streakDays {
    var cursor = _today;
    if (!_hasCompletedOn(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (_hasCompletedOn(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  bool _hasCompletedOn(DateTime date) => workoutsOn(
    date,
  ).any((workout) => workout.status == WorkoutStatus.completed);

  int get workoutsThisMonth => _workouts
      .where((w) => w.date.month == _today.month && w.date.year == _today.year)
      .length;

  int get completedThisMonth => _workouts
      .where(
        (w) =>
            w.date.month == _today.month &&
            w.date.year == _today.year &&
            w.status == WorkoutStatus.completed,
      )
      .length;

  /// Share of this month's sessions actually finished, 0.0-1.0. Splits out
  /// as its own getter because the calendar and the profile both show it and
  /// should never disagree.
  double get consistency {
    final scheduled = workoutsThisMonth;
    if (scheduled == 0) return 0;
    return completedThisMonth / scheduled;
  }

  int get consistencyPercent => (consistency * 100).round();

  Metric? metricById(String id) {
    for (final metric in _metrics) {
      if (metric.id == id) return metric;
    }
    return null;
  }

  // --- Writes ----------------------------------------------------------------

  /// Adds a workout, assigning an id when the caller did not pick one.
  void addWorkout(Workout workout) {
    final id = workout.id.isEmpty ? 'w${_nextId++}' : workout.id;
    _workouts.add(workout.id.isEmpty ? workout.copyWith(id: id) : workout);
    _sort();
    notifyListeners();
  }

  /// Replaces the workout with the same id. Returns false when nothing
  /// matched, so callers can surface "not found" instead of silently
  /// appearing to save.
  bool updateWorkout(Workout workout) {
    final index = _workouts.indexWhere((w) => w.id == workout.id);
    if (index == -1) return false;
    _workouts[index] = workout;
    _sort();
    notifyListeners();
    return true;
  }

  bool deleteWorkout(String id) {
    final before = _workouts.length;
    _workouts.removeWhere((w) => w.id == id);
    final deleted = _workouts.length != before;
    if (deleted) notifyListeners();
    return deleted;
  }

  /// Flips one set and re-derives the session status.
  ///
  /// Marking the last set done completes the workout, because a user who
  /// finished every set should not have to press a second button to close
  /// the session. Un-checking it reopens the workout just as silently.
  void toggleSet(String workoutId, int logIndex, int setIndex) {
    final workout = byId(workoutId);
    if (workout == null) return;
    if (logIndex < 0 || logIndex >= workout.logs.length) return;

    final log = workout.logs[logIndex];
    if (setIndex < 0 || setIndex >= log.sets.length) return;

    final sets = List.of(log.sets);
    sets[setIndex] = sets[setIndex].copyWith(
      completed: !sets[setIndex].completed,
    );

    final logs = List.of(workout.logs);
    logs[logIndex] = log.copyWith(sets: sets);

    final allDone = logs.every((l) => l.isFinished);
    final updated = workout.copyWith(
      logs: logs,
      status: allDone ? WorkoutStatus.completed : WorkoutStatus.planned,
    );

    updateWorkout(updated);
  }

  void updateMetric(String id, double value) {
    final index = _metrics.indexWhere((m) => m.id == id);
    if (index == -1) return;
    _metrics[index] = _metrics[index].copyWith(value: value);
    notifyListeners();
  }

  void updateProfile(ProfileStats profile) {
    _profile = profile;
    notifyListeners();
  }

  void _sort() {
    _workouts.sort((a, b) => a.date.compareTo(b.date));
  }
}
