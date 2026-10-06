import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Thin determinate bar for completion ratios.
///
/// The value animates between states instead of jumping, because a set
/// being ticked off should read as progress continuing rather than the bar
/// teleporting. Callers on the reduced-motion path pass [duration] of zero.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 4,
    this.color,
    this.trackColor,
    this.duration = AppMotion.ui,
  });

  /// 0.0-1.0. Values outside the range are clamped rather than asserted so a
  /// stale calculation cannot throw inside a build.
  final double value;
  final double height;
  final Color? color;
  final Color? trackColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final clamped = value.clamp(0.0, 1.0);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return ClipRRect(
      borderRadius: AppRadius.pill,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: trackColor ?? scheme.surfaceContainerHighest),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: clamped),
              duration: reduceMotion ? Duration.zero : duration,
              curve: AppMotion.easeOut,
              builder: (context, animated, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: animated,
                child: ColoredBox(color: color ?? scheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
