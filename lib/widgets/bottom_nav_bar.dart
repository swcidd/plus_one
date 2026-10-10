import 'package:flutter/material.dart';

import '../navigation/app_tab.dart';

/// The persistent destination bar.
///
/// A thin wrapper over [NavigationBar] rather than a raw Material widget for
/// three reasons: it names the destination set in one place so a fifth tab is
/// a one-line enum change, it gives every bar the same keyboard and semantics
/// behaviour, and it keeps the bar's chrome in [NavigationBarThemeData] where
/// the rest of the app's styling lives.
///
/// Built from the enum rather than a passed-in list of labels so the bar cannot
/// drift out of step with the routes: an entry here and a route there are the
/// same declaration.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AppTab selected;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selected.index,
      // Resolves an index back to a tab so callers pass a destination rather
      // than a positional integer, which is what lets the enum stay the single
      // source of truth for ordering.
      onDestinationSelected: (index) => onSelected(AppTab.values[index]),
      destinations: [
        for (final tab in AppTab.values)
          NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.selectedIcon),
            label: tab.label,
            // Long press opens nothing, so the tooltip is what makes a
            // destination's name reachable without leaving the bar.
            tooltip: tab.label,
          ),
      ],
    );
  }
}
