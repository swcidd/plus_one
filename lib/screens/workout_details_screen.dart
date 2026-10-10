import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_pill.dart';

/// Confirmation with an escape hatch, used for every reversible state change
/// on this screen. Capturing the previous workout before the mutation is what
/// makes UNDO a real rollback rather than a best-effort inverse.
void _showUndoSnack(
  BuildContext context,
  WorkoutProvider provider,
  String message,
  Workout previous,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () => provider.updateWorkout(previous),
      ),
    ),
  );
}

/// One session, with its sets tickable in place.
///
/// Reachable from the dashboard and the workout list through the named
/// `/workout` route, which carries the workout id rather than the object so
/// the screen always renders the provider's current copy and picks up every
/// mutation the moment it happens.
class WorkoutDetailsScreen extends StatelessWidget {
  const WorkoutDetailsScreen({super.key, this.route});

  /// The route the shell pushes. Accepting the [RouteSettings] lets the screen
  /// read the id out of a `/workout/:id` path as well as a route argument, so a
  /// deep link and an in-app push resolve the same way.
  final RouteSettings? route;

  /// Builds a path for [id], e.g. `detailRoute('upper-body')` →
  /// `/workout/upper-body`. Pushing the named route with an argument still
  /// works, but going through the path keeps one canonical form per
  /// destination.
  static String routeFor(String id) => '$routeName/$id';

  static const String routeName = '/workout';

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final id = switch (arguments) {
      String value => value,
      Workout value => value.id,
      _ => _idFromPath(route?.name),
    };

    final provider = context.watch<WorkoutProvider>();
    final workout = id == null ? null : provider.byId(id);

    if (workout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout Detail')),
        body: EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Session not found',
          message: 'It may have been removed from your calendar.',
          actionLabel: 'Go back',
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Detail'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'delete') _confirmDelete(context, workout);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Delete workout')),
            ],
          ),
        ],
      ),
      body: _Body(workout: workout),
      bottomNavigationBar: _FinishBar(workout: workout),
    );
  }

  /// Pulls the id out of `/workout/<id>`, returning null for the bare route.
  static String? _idFromPath(String? routeName) {
    if (routeName == null) return null;
    final segments = routeName.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) return null;
    return Uri.decodeComponent(segments[1]);
  }

  Future<void> _confirmDelete(BuildContext context, Workout workout) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<WorkoutProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this workout?'),
        content: Text(
          '"${workout.title}" and its ${workout.totalSets} sets will be '
          'removed from your calendar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    provider.deleteWorkout(workout.id);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text('"${workout.title}" deleted')),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.workout});

  final Workout workout;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _summaryKey = GlobalKey();
  final GlobalKey _exercisesKey = GlobalKey();

  Workout get _workout => widget.workout;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Reveals an anchor without snapping, so "Start Session" moves the eye to
  /// the first unfinished exercise instead of teleporting the list.
  void _scrollTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    final instant = MediaQuery.disableAnimationsOf(context);
    Scrollable.ensureVisible(
      target,
      duration: instant ? Duration.zero : AppMotion.route,
      curve: AppMotion.easeOut,
      alignment: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final firstUnfinished = _workout.logs.indexWhere((log) => !log.isFinished);

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        KeyedSubtree(
          key: _summaryKey,
          child: _SummaryCard(workout: _workout),
        ),
        const SizedBox(height: 20),
        KeyedSubtree(
          key: _exercisesKey,
          child: SectionHeader(
            label: 'Exercises',
            actionLabel: '${_workout.logs.length} TOTAL',
          ),
        ),
        const SizedBox(height: 4),
        if (_workout.logs.isEmpty)
          EmptyState(
            icon: Icons.fitness_center_outlined,
            title: 'No exercises yet',
            message: 'Add the first movement to start logging this session.',
            actionLabel: 'Add exercise',
            onAction: () => _promptForExercise(context),
          )
        else ...[
          for (var i = 0; i < _workout.logs.length; i++)
            _ExercisePanel(
              index: i,
              log: _workout.logs[i],
              workoutId: _workout.id,
              canRemove: _workout.logs.length > 1,
              highlighted: i == firstUnfinished,
            ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _promptForExercise(context),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Custom Exercise'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: AppRadius.card,
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap a checkbox to log a set. Finishing the last set closes '
                  'the session automatically.',
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _promptForExercise(BuildContext context) async {
    final controller = TextEditingController();
    final provider = context.read<WorkoutProvider>();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add exercise'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Exercise name',
            hintText: 'Face Pull',
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    controller.dispose();
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    provider.addExercise(
      _workout.id,
      ExerciseLog(
        exercise: Exercise(
          name: trimmed,
          equipment: 'Bodyweight',
          muscleGroups: const ['Full Body'],
        ),
        sets: const [WorkoutSet(reps: 10, weightKg: 0)],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = context.read<WorkoutProvider>();
    final isDone = workout.isDone;

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
          Text(workout.title, style: textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: [
              StatPill(
                value: '${workout.durationMin}',
                label: 'MIN TOTAL',
                icon: Icons.timer_outlined,
              ),
              StatPill(
                value: '${workout.estimatedKcal}',
                label: 'KCAL',
                icon: Icons.local_fire_department_outlined,
              ),
              StatPill(
                value: '${workout.totalSets}',
                label: workout.totalSets == 1 ? 'SET' : 'SETS',
                icon: Icons.fitness_center_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isDone
                      ? () {
                          final previous = workout;
                          provider.reopenWorkout(workout.id);
                          _showUndoSnack(
                            context,
                            provider,
                            'Session reopened',
                            previous,
                          );
                        }
                      : () => _revealExercises(context),
                  icon: Icon(
                    isDone ? Icons.replay_rounded : Icons.play_arrow_rounded,
                    size: 18,
                  ),
                  label: Text(isDone ? 'Reopen Session' : 'Start Session'),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _revealExercises(context),
                child: const Text('View Log'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _revealExercises(BuildContext context) {
    final state = context.findAncestorStateOfType<_BodyState>();
    if (state != null) state._scrollTo(state._exercisesKey);
  }
}

class _ExercisePanel extends StatelessWidget {
  const _ExercisePanel({
    required this.index,
    required this.log,
    required this.workoutId,
    required this.canRemove,
    required this.highlighted,
  });

  final int index;
  final ExerciseLog log;
  final String workoutId;
  final bool canRemove;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = context.read<WorkoutProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: highlighted ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: index == 0,
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Text(
              (index + 1).toString().padLeft(2, '0'),
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            log.exercise.name,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${log.exercise.equipment} · '
            '${log.exercise.muscleGroups.join(', ')}',
            style: textTheme.bodySmall,
          ),
          children: [
            _SetTable(log: log, workoutId: workoutId, logIndex: index),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'VOLUME: ${log.volume.toStringAsFixed(0)} KG',
                    style: context.text.labelCaps,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => provider.addSet(workoutId, index),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('SET'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 36),
                  ),
                ),
              ],
            ),
            if (canRemove)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => provider.removeExercise(workoutId, index),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(
                    'Remove exercise',
                    style: textTheme.bodySmall?.copyWith(color: scheme.error),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SetTable extends StatelessWidget {
  const _SetTable({
    required this.log,
    required this.workoutId,
    required this.logIndex,
  });

  final ExerciseLog log;
  final String workoutId;
  final int logIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (log.sets.isEmpty) {
      return Text('No sets logged yet.', style: textTheme.bodySmall);
    }

    return Column(
      children: [
        Row(
          children: [
            _cell(textTheme.labelSmall, 'SET', flex: 3),
            _cell(textTheme.labelSmall, 'REPS', flex: 3),
            _cell(textTheme.labelSmall, 'WEIGHT', flex: 4),
            const SizedBox(width: 34),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 4),
        for (var i = 0; i < log.sets.length; i++) ...[
          Divider(color: scheme.outlineVariant),
          _SetRow(
            log: log,
            workoutId: workoutId,
            logIndex: logIndex,
            setIndex: i,
          ),
        ],
      ],
    );
  }

  Widget _cell(TextStyle? style, String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(text, style: style, overflow: TextOverflow.ellipsis),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.log,
    required this.workoutId,
    required this.logIndex,
    required this.setIndex,
  });

  final ExerciseLog log;
  final String workoutId;
  final int logIndex;
  final int setIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = context.read<WorkoutProvider>();
    final set = log.sets[setIndex];
    final canRemove = log.sets.length > 1;
    final valueStyle = textTheme.bodyMedium?.copyWith(
      fontWeight: set.completed ? FontWeight.w700 : FontWeight.w500,
      color: set.completed ? scheme.onSurface : scheme.onSurfaceVariant,
    );

    return Row(
      children: [
        _cell(
          textTheme.labelSmall,
          'SET ${(setIndex + 1).toString().padLeft(2, '0')}',
          flex: 3,
        ),
        _cell(valueStyle, '${set.reps} REPS', flex: 3),
        _cell(valueStyle, '${set.weightKg.toStringAsFixed(0)} KG', flex: 4),
        SizedBox(
          width: 34,
          height: 34,
          child: Checkbox(
            value: set.completed,
            onChanged: (_) => provider.toggleSet(workoutId, logIndex, setIndex),
          ),
        ),
        SizedBox(
          width: 30,
          height: 34,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 16,
            tooltip: 'Remove set',
            onPressed: canRemove
                ? () => provider.removeSet(workoutId, logIndex, setIndex)
                : null,
            icon: Icon(
              Icons.close_rounded,
              color: canRemove
                  ? scheme.onSurfaceVariant
                  : scheme.outlineVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell(TextStyle? style, String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(text, style: style, overflow: TextOverflow.ellipsis),
    );
  }
}

class _FinishBar extends StatelessWidget {
  const _FinishBar({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = context.read<WorkoutProvider>();
    final isDone = workout.isDone;
    final volume = workout.logs.fold<double>(0, (sum, log) => sum + log.volume);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('TOTAL VOLUME', style: textTheme.labelSmall),
                  Text(
                    '${volume.toStringAsFixed(0)} KG',
                    style: context.text.metric,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isDone
                  ? null
                  : () {
                      final previous = workout;
                      provider.completeWorkout(workout.id);
                      _showUndoSnack(
                        context,
                        provider,
                        'Workout finished. Nice work.',
                        previous,
                      );
                    },
              child: Text(isDone ? 'Finished' : 'Finish Workout'),
            ),
          ],
        ),
      ),
    );
  }
}
