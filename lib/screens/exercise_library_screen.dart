import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../providers/workout_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/brand_app_bar.dart';
import '../widgets/empty_state.dart';
import 'navigation_shell.dart';

/// Browse the exercises available for a session, searchable and filterable.
///
/// This is the screen the exercise API plugs into: the wiring, the states and
/// the selection contract are all in place here, so adding a remote source
/// later means replacing [_catalogue] and nothing else.
///
/// Selection returns through [Navigator.pop] with the chosen [Exercise] rather
/// than writing to the provider directly. The library does not own a workout,
/// so it has no business mutating one — handing the result back keeps the
/// caller's edit isolated and undoable by simply not accepting it.
class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key, this.onSelectTab});

  final ValueChanged<AppTab>? onSelectTab;

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _search = TextEditingController();
  String? _muscleFilter;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final catalogue = _catalogue();
    final muscles = _musclesOf(catalogue);
    final results = _applyFilters(catalogue);

    return Scaffold(
      appBar: BrandAppBar(
        onAvatar: () => widget.onSelectTab?.call(AppTab.profile),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search exercises',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => _search.clear(),
                      ),
                filled: true,
                fillColor: scheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.control,
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.control,
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.control,
                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _muscleFilter == null,
                  onTap: () => setState(() => _muscleFilter = null),
                ),
                for (final muscle in muscles) ...[
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: muscle,
                    selected: _muscleFilter == muscle,
                    onTap: () => setState(() => _muscleFilter = muscle),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: results.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: _search.text.isEmpty
                        ? 'No exercises yet'
                        : 'No matches for "${_search.text}"',
                    message: _search.text.isEmpty
                        ? 'Exercises you log will be listed here to reuse.'
                        : 'Try a different name or clear the muscle filter.',
                    actionLabel: _search.text.isEmpty ? null : 'Clear search',
                    onAction: _search.text.isEmpty
                        ? null
                        : () {
                            _search.clear();
                            setState(() => _muscleFilter = null);
                          },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final exercise = results[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        title: Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          [
                            ...exercise.muscleGroups,
                            if (exercise.equipment.isNotEmpty)
                              exercise.equipment,
                          ].join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).pop(exercise),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Every distinct exercise the user has logged, alphabetically.
  ///
  /// Derived from the logged sessions rather than a hard-coded list, so the
  /// library is guaranteed to agree with what the app can actually record.
  /// Swapping this body for a remote fetch is the only change needed to point
  /// the screen at an API.
  List<Exercise> _catalogue() {
    final seen = <String, Exercise>{};
    for (final workout in context.read<WorkoutProvider>().workouts) {
      for (final log in workout.logs) {
        seen.putIfAbsent(log.exercise.name, () => log.exercise);
      }
    }
    final all = seen.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return all;
  }

  List<String> _musclesOf(List<Exercise> catalogue) {
    final muscles = <String>{};
    for (final exercise in catalogue) {
      muscles.addAll(exercise.muscleGroups);
    }
    final sorted = muscles.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  List<Exercise> _applyFilters(List<Exercise> catalogue) {
    final query = _search.text.trim().toLowerCase();
    return catalogue.where((exercise) {
      final matchesMuscle =
          _muscleFilter == null ||
          exercise.muscleGroups.contains(_muscleFilter);
      final matchesQuery =
          query.isEmpty || exercise.name.toLowerCase().contains(query);
      return matchesMuscle && matchesQuery;
    }).toList();
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? scheme.primary : scheme.surfaceContainerLowest,
      borderRadius: AppRadius.pill,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pill,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: context.text.labelCaps.copyWith(
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
