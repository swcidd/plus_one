import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/metric.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../screens/workout_details_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/brand_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/metric_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_pill.dart';
import '../widgets/workout_card.dart';

/// The dashboard: what is on today, what the body has done, and how the
/// week is going.
///
/// Everything is derived from the provider rather than held locally, so
/// ticking a set on the detail screen changes the ring, the checklist and
/// the "left" count the moment the user comes back.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenProfile, this.onOpenWorkouts});

  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenWorkouts;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final focus = provider.focusWorkout;
    final profile = provider.profile;
    final firstName = profile.name.split(' ').first;

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 18
        ? 'Good Afternoon'
        : 'Good Evening';

    return Scaffold(
      appBar: BrandAppBar(onAvatar: onOpenProfile),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            '$greeting, $firstName',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                DateFormat('EEE, MMM d').format(provider.today).toUpperCase(),
                style: context.text.labelCaps,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (focus?.title ?? 'No session scheduled').toUpperCase(),
                  style: context.text.labelCaps,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(
            label: "Today's plan",
            actionLabel: 'All workouts',
            onAction: onOpenWorkouts,
          ),
          if (focus == null)
            const EmptyState(
              icon: Icons.event_available_outlined,
              title: 'Nothing scheduled today',
              message: 'Pick a session from your workouts to get going.',
            )
          else ...[
            WorkoutCard(
              workout: focus,
              actions: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                      WorkoutDetailsScreen.routeName,
                      arguments: focus.id,
                    ),
                    icon: Icon(
                      focus.completedSets > 0 && !focus.isDone
                          ? Icons.play_arrow_rounded
                          : Icons.event_rounded,
                      size: 18,
                    ),
                    label: Text(
                      focus.isDone
                          ? 'View Summary'
                          : focus.completedSets > 0
                          ? 'Resume Workout Session'
                          : 'Start Session',
                    ),
                  ),
                ),
              ],
            ),
            if (focus.logs.isNotEmpty) ...[
              const SizedBox(height: 12),
              _PlanBreakdown(workout: focus),
            ],
          ],
          const SizedBox(height: 24),
          SectionHeader(label: 'Daily goals'),
          const SizedBox(height: 8),
          _rowOf(
            context,
            perRow: 3,
            compact: true,
            ids: const ['calories', 'active-minutes', 'steps'],
            metrics: provider.metrics,
          ),
          const SizedBox(height: 24),
          SectionHeader(label: "Today's vitals"),
          const SizedBox(height: 8),
          _rowOf(
            context,
            perRow: 2,
            ids: const ['heart-rate', 'hydration', 'sleep', 'distance'],
            metrics: provider.metrics,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: SectionHeader(label: "Today's progress")),
              if (focus != null && focus.totalSets > 0)
                StatPill(
                  value: '${focus.setsRemaining}',
                  label: 'LEFT',
                  icon: Icons.album_outlined,
                ),
            ],
          ),
          const SizedBox(height: 8),
          _ComplianceCard(provider: provider),
          const SizedBox(height: 24),
          SectionHeader(
            label: 'Recent sessions',
            actionLabel: 'View all',
            onAction: onOpenWorkouts,
          ),
          const SizedBox(height: 8),
          ..._recentSessions(provider).map(
            (workout) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WorkoutCard(
                workout: workout,
                dense: true,
                onTap: () => Navigator.of(context).pushNamed(
                  WorkoutDetailsScreen.routeName,
                  arguments: workout.id,
                ),
              ),
            ),
          ),
          if (_recentSessions(provider).isEmpty)
            const EmptyState(
              icon: Icons.history_rounded,
              title: 'No finished sessions yet',
              message: 'Completed workouts will show up here.',
            ),
        ],
      ),
    );
  }

  /// Lays out a fixed set of metrics, chunked [perRow] at a time. The ids
  /// are explicit rather than "whatever is in the list" so reordering the
  /// seed data cannot silently rearrange the dashboard.
  Widget _rowOf(
    BuildContext context, {
    required List<String> ids,
    required List<Metric> metrics,
    int perRow = 2,
    bool compact = false,
  }) {
    final chosen = [
      for (final id in ids)
        if (metrics.any((m) => m.id == id))
          metrics.firstWhere((m) => m.id == id),
    ];
    if (chosen.isEmpty) return const SizedBox.shrink();

    final rows = <List<Metric>>[];
    for (var i = 0; i < chosen.length; i += perRow) {
      rows.add(chosen.skip(i).take(perRow).toList());
    }

    return Column(
      children: [
        for (final row in rows) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < row.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: MetricTile(metric: row[i], compact: compact),
                  ),
                ],
                if (row.length == 1) ...[
                  const SizedBox(width: 10),
                  const Spacer(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  static List<Workout> _recentSessions(WorkoutProvider provider) {
    final finished =
        provider.workouts
            .where(
              (w) =>
                  w.date.isBefore(provider.today) &&
                  w.status == WorkoutStatus.completed,
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return finished.take(3).toList();
  }
}

/// Ring plus per-exercise checklist: the compact answer to "what is left".
class _PlanBreakdown extends StatelessWidget {
  const _PlanBreakdown({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _ProgressRing(workout: workout),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EXERCISES', style: context.text.labelCaps),
                  const SizedBox(height: 8),
                  for (final log in workout.logs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            log.isFinished
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 15,
                            color: log.isFinished
                                ? scheme.onSurface
                                : scheme.outline,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              log.exercise.name,
                              style: textTheme.bodySmall?.copyWith(
                                color: log.isFinished
                                    ? scheme.onSurface
                                    : scheme.onSurfaceVariant,
                                decoration: log.isFinished
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${log.completedSets}/${log.totalSets}',
                            style: textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final instant = MediaQuery.disableAnimationsOf(context);

    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: workout.progress),
              duration: instant ? Duration.zero : AppMotion.ui,
              curve: AppMotion.easeOut,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 7,
                strokeCap: StrokeCap.round,
                backgroundColor: scheme.surfaceContainerHighest,
                color: scheme.primary,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${workout.setsRemaining}', style: context.text.metric),
              Text('LEFT', style: textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// Seven days of finished training against the daily active-minutes goal.
class _ComplianceCard extends StatelessWidget {
  const _ComplianceCard({required this.provider});

  final WorkoutProvider provider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final days = List.generate(7, (i) {
      final day = provider.today.subtract(Duration(days: 6 - i));
      return provider
          .workoutsOn(day)
          .where((w) => w.status == WorkoutStatus.completed);
    }).toList();

    final minutes = days
        .map(
          (sessions) => sessions.fold<int>(0, (sum, w) => sum + w.durationMin),
        )
        .toList();
    final labels = [
      for (var i = 6; i >= 0; i--)
        DateFormat.E().format(provider.today.subtract(Duration(days: i))),
    ];
    final target =
        provider.metricById('active-minutes')?.target?.toDouble() ?? 60;
    final peak = minutes.fold<int>(0, (max, v) => v > max ? v : max);
    final maxY = [
      peak.toDouble(),
      target * 1.3,
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Daily Compliance', style: textTheme.headlineSmall),
              ),
              Text(
                '${provider.consistencyPercent}%',
                style: context.text.dataMetric.copyWith(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Minutes trained per day against a ${target.toStringAsFixed(0)} '
            'minute goal. ${provider.consistencyPercent}% adherence this month.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          if (peak == 0)
            const EmptyState(
              icon: Icons.bar_chart_rounded,
              title: 'No training logged this week',
              message: 'Finish a session to fill in this chart.',
            )
          else
            SizedBox(
              height: 148,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: false),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[index].substring(0, 1),
                              style: textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: target,
                        color: scheme.outline,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ],
                  ),
                  barGroups: [
                    for (var i = 0; i < minutes.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: minutes[i].toDouble(),
                            width: 16,
                            color: i == minutes.length - 1
                                ? scheme.primary
                                : scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                  ],
                ),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : AppMotion.ui,
                curve: AppMotion.easeOut,
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              _legendDot(scheme.primary),
              const SizedBox(width: 6),
              Text('TODAY', style: textTheme.labelSmall),
              const SizedBox(width: 14),
              _legendDot(scheme.surfaceContainerHighest),
              const SizedBox(width: 6),
              Text('EARLIER', style: textTheme.labelSmall),
              const SizedBox(width: 14),
              Container(width: 14, height: 2, color: scheme.outline),
              const SizedBox(width: 6),
              Text('GOAL', style: textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
