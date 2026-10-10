import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/workout_provider.dart';
import 'screens/home_screen.dart';
import 'screens/workout_details_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PlusOneApp());
}

/// Route for the dashboard.
abstract final class AppRoutes {
  static const String home = '/';
}

/// Root of the application.
///
/// The dashboard is the only destination declared in [routes]; the workout
/// detail screen is built by [onGenerateRoute] because it is parameterised. A
/// `routes` entry can only match an exact string, so `/workout/:id` needed a
/// RouteFactory — and putting the id in the path rather than a route argument
/// makes a deep link shareable.
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
        initialRoute: AppRoutes.home,
        onGenerateRoute: _onGenerateRoute,
        routes: {AppRoutes.home: (_) => const HomeScreen()},
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
