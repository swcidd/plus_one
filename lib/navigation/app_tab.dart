import 'package:flutter/material.dart';

/// The four root destinations, in tab-bar order.
///
/// Modelled as an enum rather than four callbacks so the bar, the route table
/// and any in-app cross-reference all resolve a destination the same way. A
/// destination reachable by tap but not by route would leave the detail screens
/// unable to send the user back where they came from.
///
/// Kept free of widget imports so a screen can reference a destination without
/// depending on the shell that hosts it.
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

  /// Resolves a route name to its tab, falling back to [AppTab.home].
  ///
  /// Used by the route table, where an unmatched path has to land somewhere
  /// rather than throw.
  static AppTab fromRoute(String? routeName) {
    for (final tab in AppTab.values) {
      if (tab.routeName == routeName) return tab;
    }
    return AppTab.home;
  }
}
