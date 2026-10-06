import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/workout_provider.dart';
import 'screens/workout_details_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/app_typography.dart';

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
        home: const _ThemePreview(),
      ),
    );
  }
}

/// Temporary surface used until the real screens land, so every commit on
/// this branch still builds and can be inspected in the simulator.
class _ThemePreview extends StatelessWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Plus One')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Headline', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Body copy sits on the surface colour.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Primary action'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: AppRadius.card,
              ),
              child: Text('42', style: context.text.dataMetric),
            ),
          ],
        ),
      ),
    );
  }
}
