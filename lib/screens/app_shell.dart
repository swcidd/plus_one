import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/app_tab.dart';
import '../providers/workout_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/brand_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/new_workout_dialog.dart';
import 'home_screen.dart';
import 'workout_details_screen.dart';

/// Hosts the four tabs and owns which one is visible.
///
/// Tabs live in an [IndexedStack] rather than being rebuilt on each tap, so a
/// tab keeps whatever the user left on it. Rebuilding on tap would silently
/// discard that state every time they came back.
///
/// Each tab is built lazily and kept once built. The stack alone would construct
/// all four on first paint, running work for screens the user may never open.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.tab = AppTab.home});

  /// Which tab to show first. Taken from the route so `/calendar` opens the
  /// calendar rather than the home tab wearing a calendar URL.
  final AppTab tab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AppTab _active = widget.tab;

  void _select(AppTab tab) {
    if (_active == tab) return;
    setState(() => _active = tab);
  }

  /// The bar's action, which does one of two things depending on the account.
  ///
  /// With a session to train it opens that session. With nothing scheduled it
  /// opens the create form, because that is the only sensible next step for an
  /// account with no sessions - and the one the user is reaching for.
  Future<void> _startWorkout() async {
    final provider = context.read<WorkoutProvider>();
    final target = provider.focusWorkout ?? provider.workouts.lastOrNull;
    final navigator = Navigator.of(context);

    if (target != null) {
      navigator.pushNamed(WorkoutDetailsScreen.routeFor(target.id));
      return;
    }

    final created = await NewWorkoutDialog.show(context);
    if (created == null) return;

    // Held locally rather than read through context again: the dialog closes
    // above this widget, and the navigator it pushed onto is the same one, so
    // the detail screen has to be pushed here to sit on top of the shell
    // instead of inside the dismissed dialog's route.
    final stored = provider.addWorkout(created);
    navigator.pushNamed(WorkoutDetailsScreen.routeFor(stored.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _active.index,
        children: [
          for (final tab in AppTab.values)
            _LazyTab(tab: tab, active: _active, select: _select),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        selected: _active,
        onSelected: _select,
        onWorkoutPressed: _startWorkout,
      ),
    );
  }
}

/// Builds one tab on first visit and keeps it thereafter.
class _LazyTab extends StatefulWidget {
  const _LazyTab({
    required this.tab,
    required this.active,
    required this.select,
  });

  final AppTab tab;
  final AppTab active;
  final ValueChanged<AppTab> select;

  @override
  State<_LazyTab> createState() => _LazyTabState();
}

class _LazyTabState extends State<_LazyTab> {
  bool _visited = false;

  @override
  void initState() {
    super.initState();
    if (widget.active == widget.tab) _visited = true;
  }

  @override
  void didUpdateWidget(_LazyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `active` arrives as a plain field rather than an inherited dependency, so
    // didChangeDependencies does not fire when the tab changes and the latch has
    // to be updated here instead.
    if (!_visited && widget.active == widget.tab) _visited = true;
  }

  @override
  Widget build(BuildContext context) {
    return _visited ? _body(widget.tab) : const SizedBox.shrink();
  }

  Widget _body(AppTab tab) {
    return switch (tab) {
      AppTab.home => HomeScreen(onSelectTab: widget.select),
      AppTab.calendar => const PlaceholderTabScreen(tab: AppTab.calendar),
      AppTab.library => const PlaceholderTabScreen(tab: AppTab.library),
      AppTab.profile => const PlaceholderTabScreen(tab: AppTab.profile),
    };
  }
}

/// Stands in for a tab that is routed and reachable but not built yet.
///
/// Exists so the bar can be demonstrated without shipping three dead controls
/// that do nothing on tap. Each one states plainly what it will do, which is
/// more honest than a spinner or a blank page, and gives the destination a
/// real name in the UI so the navigation is reviewable before the screens land.
///
/// The next slice replaces these one at a time; nothing else has to change.
class PlaceholderTabScreen extends StatelessWidget {
  const PlaceholderTabScreen({super.key, required this.tab});

  final AppTab tab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandAppBar(),
      body: EmptyState(
        icon: tab.icon,
        title: '${tab.label} is next',
        message: _messageFor(tab),
      ),
    );
  }

  static String _messageFor(AppTab tab) => switch (tab) {
    AppTab.calendar =>
      'A month grid with the sessions you have logged, and the day you select '
          'opened from the dashboard.',
    AppTab.library =>
      'The exercise catalogue, searchable and filterable by muscle group.',
    AppTab.profile =>
      'Your training totals, personal records and the settings behind them.',
    AppTab.home => 'The dashboard.',
  };
}
