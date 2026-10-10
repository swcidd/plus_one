import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation/app_tab.dart';
import 'providers/workout_provider.dart';
import 'screens/app_shell.dart';
import 'screens/workout_details_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PlusOneApp());
}

/// Root of the application.
///
/// The four tabs are declared in [routes], each resolving to the shell with its
/// own tab selected, so every destination has a real URL. The workout detail
/// screen is built by [onGenerateRoute] because it is parameterised: a
/// `routes` entry can only match an exact string, so `/workout/:id` needed a
/// RouteFactory. Putting the id in the path rather than a route argument makes
/// the resulting link shareable.
///
/// Falls through to null for anything unrecognised, so Flutter raises its own
/// "unknown route" error instead of this method quietly substituting the wrong
/// screen.
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
            tab.routeName: (_) => AppShell(tab: tab),
        },
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null) return null;

    final segments = name.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty &&
        '/${segments.first}' == WorkoutDetailsScreen.routeName) {
      return MaterialPageRoute<void>(
        builder: (_) => WorkoutDetailsScreen(route: settings),
        settings: settings,
      );
    }

    return null;
  }
}
