import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/brand_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/workout_card.dart';
import 'navigation_shell.dart';
import 'workout_details_screen.dart';

/// Month grid plus the sessions logged on the selected day.
///
/// The grid marks days that hold a session with a filled dot and today with an
/// outlined box, and the pair is explained by a legend underneath. Two distinct
/// markers beat one overloaded one: a user reading the grid should be able to
/// tell "there is a workout here" from "this is now" without hovering.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.onSelectTab});

  final ValueChanged<AppTab>? onSelectTab;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _month = DateTime(today.year, today.month);
    _selected = DateTime(today.year, today.month, today.day);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final selectedSessions = provider.workoutsOn(_selected);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: BrandAppBar(
        onAvatar: () => widget.onSelectTab?.call(AppTab.profile),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _MonthHeader(
            month: _month,
            onPrevious: () => _shiftMonth(-1),
            onNext: () => _shiftMonth(1),
          ),
          const SizedBox(height: 16),
          _MonthGrid(
            month: _month,
            selected: _selected,
            onSelect: (day) => setState(() => _selected = day),
          ),
          const SizedBox(height: 10),
          _GridLegend(today: provider.today),
          const SizedBox(height: 24),
          _SelectedDay(
            date: _selected,
            sessions: selectedSessions,
            onStart: () => widget.onSelectTab?.call(AppTab.home),
          ),
          const SizedBox(height: 24),
          Text('UPCOMING', style: context.text.labelCaps),
          const SizedBox(height: 8),
          ..._upcoming(provider).map(
            (workout) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WorkoutCard(
                workout: workout,
                dense: true,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(WorkoutDetailsScreen.routeFor(workout.id)),
              ),
            ),
          ),
          if (_upcoming(provider).isEmpty)
            EmptyState(
              icon: Icons.event_available_outlined,
              title: 'Nothing scheduled',
              message: 'No future sessions on the calendar.',
            ),
          const SizedBox(height: 8),
          Text(
            'Tapping a day shows what you logged. Open a session to review '
            'every set.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// Sessions dated after today, nearest first, capped so the screen does not
  /// turn into an unbounded list.
  List<Workout> _upcoming(WorkoutProvider provider) {
    final future =
        provider.workouts.where((w) => w.date.isAfter(provider.today)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return future.take(3).toList();
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: 'Previous month',
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Text(
            DateFormat.yMMMM().format(month),
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: 'Next month',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

/// Seven-column month grid.
///
/// Starts the week on Monday, which matches how lifters plan a week and avoids
/// a Sunday-first column that leaves the first row eight cells wide.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  static const List<String> _weekdays = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final today = provider.today;

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // DateTime.weekday is 1 (Mon) to 7 (Sun), so the offset is one less than
    // the raw value.
    final leading = DateTime(month.year, month.month).weekday - 1;
    final cellCount = leading + daysInMonth;
    final rows = (cellCount / 7).ceil();

    return Column(
      children: [
        Row(
          children: [
            for (final label in _weekdays)
              Expanded(
                child: Center(
                  child: Text(label, style: context.text.labelCaps),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (var row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                for (var column = 0; column < 7; column++)
                  Expanded(
                    child: _DayCell(
                      date: _dateAt(column - leading + 1, month, daysInMonth),
                      inMonth:
                          column - leading + 1 >= 1 &&
                          column - leading + 1 <= daysInMonth,
                      isToday: _sameDay(
                        column - leading + 1,
                        month,
                        daysInMonth,
                        today,
                      ),
                      isSelected: _sameDay(
                        column - leading + 1,
                        month,
                        daysInMonth,
                        selected,
                      ),
                      hasSession: _hasSession(
                        column - leading + 1,
                        month,
                        daysInMonth,
                        provider,
                      ),
                      onTap: (date) => onSelect(date),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /// Day number for a 1-based offset into the month, or null past the end.
  DateTime? _dateAt(int day, DateTime month, int daysInMonth) {
    if (day < 1 || day > daysInMonth) return null;
    return DateTime(month.year, month.month, day);
  }

  bool _sameDay(int day, DateTime month, int daysInMonth, DateTime target) {
    final date = _dateAt(day, month, daysInMonth);
    if (date == null) return false;
    return date.year == target.year &&
        date.month == target.month &&
        date.day == target.day;
  }

  bool _hasSession(
    int day,
    DateTime month,
    int daysInMonth,
    WorkoutProvider provider,
  ) {
    final date = _dateAt(day, month, daysInMonth);
    if (date == null) return false;
    return provider.workoutsOn(date).isNotEmpty;
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.hasSession,
    required this.onTap,
  });

  final DateTime? date;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final bool hasSession;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final label = date?.day.toString() ?? '';
    // Filled for the selection, outlined for today, faint for a leading or
    // trailing day from the neighbouring month so the grid keeps its shape
    // without pretending those dates belong to this month.
    Color? background;
    if (isSelected) {
      background = scheme.primary;
    } else if (isToday) {
      background = scheme.surfaceContainerHigh;
    }

    final color = isSelected
        ? scheme.onPrimary
        : inMonth
        ? scheme.onSurface
        : scheme.outline;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: date == null ? null : () => onTap(date!),
        borderRadius: AppRadius.tag,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppRadius.tag,
            border: isToday && !isSelected
                ? Border.all(color: scheme.primary, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: isToday || isSelected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 3),
              // Dot presence is what carries the "has a workout" signal; an
              // empty slot keeps the cell heights identical whether or not a
              // day is marked.
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasSession && inMonth
                      ? (isSelected ? scheme.onPrimary : scheme.primary)
                      : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridLegend extends StatelessWidget {
  const _GridLegend({required this.today});

  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text('LOGGED WORKOUT', style: context.text.labelCaps),
        const SizedBox(width: 16),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xs)),
            border: Border.all(color: scheme.primary, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          today.day == 1 ? 'FIRST OF MONTH' : 'TODAY',
          style: context.text.labelCaps,
        ),
      ],
    );
  }
}

/// Detail for whichever day is selected.
class _SelectedDay extends StatelessWidget {
  const _SelectedDay({
    required this.date,
    required this.sessions,
    required this.onStart,
  });

  final DateTime date;
  final List<Workout> sessions;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('EEE, MMM d').format(date).toUpperCase(),
                style: context.text.labelCaps,
              ),
            ),
            if (sessions.isNotEmpty)
              Text(
                '${sessions.length} ${sessions.length == 1 ? 'SESSION' : 'SESSIONS'}',
                style: context.text.labelCaps,
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (sessions.isEmpty)
          EmptyState(
            icon: Icons.event_busy_outlined,
            title: 'No workout logged',
            message: 'Nothing was recorded on this day.',
            actionLabel: 'Start a session',
            onAction: onStart,
          )
        else
          for (final workout in sessions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WorkoutCard(
                workout: workout,
                dense: true,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(WorkoutDetailsScreen.routeFor(workout.id)),
              ),
            ),
        if (sessions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Open a session to review every set.',
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
