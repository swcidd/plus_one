import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/workout_provider.dart';
import 'screens/home_screen.dart';
import 'screens/workout_details_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PlusOneApp());
}

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
        routes: {
          WorkoutDetailsScreen.routeName: (_) => const WorkoutDetailsScreen(),
        },
        // The tab callbacks are wired up with the navigation shell; passing
        // null hides the corresponding affordance rather than presenting a
        // control that does nothing yet.
        home: const HomeScreen(),
      ),
    );
  }
}
