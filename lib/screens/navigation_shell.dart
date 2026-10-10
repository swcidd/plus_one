import 'package:flutter/material.dart';

import 'calendar_screen.dart';
import 'exercise_library_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// The four root destinations, in tab-bar order.
///
/// Modelled as an enum rather than four bare callbacks so the tab bar, the
/// route table and the "go to profile" affordance on the app bar all resolve
/// the same index. A tab that is reachable by tap but not by route would mean
/// the detail screens could not push the user back to where they came from.
enum AppTab {
  home(
    routeName: '/',
    label: 'Home',
    icon: Icons.space_dashboard_outlined,
    selectedIcon: Icons.space_dashboard_rounded,
  ),
  calendar(
    routeName: '/calendar',
    label: 'Calendar',
    icon: Icons.calendar_today_outlined,
    selectedIcon: Icons.calendar_today_rounded,
  ),
  library(
    routeName: '/library',
    label: 'Library',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
  ),
  profile(
    routeName: '/profile',
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
  );

  const AppTab({
    required this.routeName,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String routeName;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  static AppTab fromRoute(String? routeName) {
    for (final tab in AppTab.values) {
      if (tab.routeName == routeName) return tab;
    }
    return AppTab.home;
  }
}

/// Hosts the four tabs and owns which one is visible.
///
/// The tabs live in an [IndexedStack] rather than being rebuilt on every tap,
/// so the calendar keeps the month the user scrolled to and the profile keeps
/// its scroll offset. That matters most for the calendar: rebuilding it on
/// each tap would snap the month back to the current one every time the user
/// returned from a workout.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialTab = AppTab.home});

  final AppTab initialTab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AppTab _active = widget.initialTab;

  void _select(AppTab tab) {
    if (_active == tab) return;
    setState(() => _active = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _active.index,
        children: [
          for (final tab in AppTab.values)
            _TabScaffold(tab: tab, active: _active, onSelect: _select),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _active.index,
        onDestinationSelected: (index) => _select(AppTab.values[index]),
        destinations: [
          for (final tab in AppTab.values)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
              tooltip: tab.label,
            ),
        ],
      ),
    );
  }
}

/// Builds one tab lazily and keeps it alive once visited.
///
/// [IndexedStack] still builds all four children, which would run the library
/// screen's future before the user ever opens it. This defers the build until
/// first visit and then holds it, giving both lazy construction and the
/// preserved-state behaviour of the stack.
class _TabScaffold extends StatefulWidget {
  const _TabScaffold({
    required this.tab,
    required this.active,
    required this.onSelect,
  });

  final AppTab tab;
  final AppTab active;
  final ValueChanged<AppTab> onSelect;

  @override
  State<_TabScaffold> createState() => _TabScaffoldState();
}

class _TabScaffoldState extends State<_TabScaffold> {
  bool _visited = false;

  @override
  void initState() {
    super.initState();
    if (widget.active == widget.tab) _visited = true;
  }

  @override
  void didUpdateWidget(_TabScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `active` arrives as a plain field, not an inherited dependency, so
    // didChangeDependencies does not fire when the tab changes and the latch
    // has to be updated here instead.
    if (!_visited && widget.active == widget.tab) _visited = true;
  }

  @override
  Widget build(BuildContext context) {
    return _visited ? _body(widget.tab) : const SizedBox.shrink();
  }

  Widget _body(AppTab tab) {
    final onSelect = widget.onSelect;
    return switch (tab) {
      AppTab.home => HomeScreen(onSelectTab: onSelect),
      AppTab.calendar => CalendarScreen(onSelectTab: onSelect),
      AppTab.library => ExerciseLibraryScreen(onSelectTab: onSelect),
      AppTab.profile => ProfileScreen(onSelectTab: onSelect),
    };
  }
}
