import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/workout_provider.dart';
import 'screens/navigation_shell.dart';
import 'screens/workout_details_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PlusOneApp());
}

/// Root of the application.
///
/// Every destination is a named route rather than a constructor call from the
/// shell, which is what makes the route table legible in one place and lets a
/// deep link open any screen directly. The four tabs resolve to the same shell
/// with a different initial tab selected, so a route that is never navigated
/// to still produces the correct screen.
///
/// The workout detail route is built by [onGenerateRoute] rather than declared
/// in [routes] because it is a parameterised path: `/workout/:id` is what the
/// route table documents, and a `routes` entry can only match an exact string.
/// The id travels in the path so the link itself is shareable and bookmarkable.
class PlusOneApp extends StatelessWidget {
  const PlusOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutProvider(),
      child: MaterialApp(
        title: '+1',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        initialRoute: AppTab.home.routeName,
        onGenerateRoute: _onGenerateRoute,
        routes: {
          for (final tab in AppTab.values)
            tab.routeName: (_) => AppShell(initialTab: tab),
        },
      ),
    );
  }

  /// Resolves a URL to a screen.
  ///
  /// Falls through to null for anything unrecognised so Flutter raises its own
  /// "unknown route" error rather than this method quietly substituting a
  /// wrong screen.
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final segments = settings.name
        ?.split('/')
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (segments != null && segments.isNotEmpty) {
      final root = '/${segments.first}';
      for (final tab in AppTab.values) {
        if (tab.routeName == root) {
          return MaterialPageRoute<void>(
            builder: (_) => AppShell(initialTab: tab),
            settings: settings,
          );
        }
      }
      if (root == WorkoutDetailsScreen.routeName) {
        return MaterialPageRoute<void>(
          builder: (_) => WorkoutDetailsScreen(route: settings),
          settings: settings,
        );
      }
    }

    return null;
  }
}
