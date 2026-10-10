import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_typography.dart';

/// The centred action in the destination bar.
///
/// A filled circle raised above the bar, labelled underneath, where every other
/// destination is an unboxed icon with its own label. The contrast is the point:
/// "start a workout" is the one thing a lifter opens the app to do, and a row of
/// four identically weighted icons would bury it at the same value as "browse
/// exercises".
class WorkoutActionButton extends StatelessWidget {
  const WorkoutActionButton({
    super.key,
    required this.onPressed,
    this.size = 52,
    this.label = 'Workout',
  });

  /// Opens a session. The button owns no state of its own, so what happens
  /// afterwards is the caller's decision - the bar does not know whether this
  /// resumes today's plan or starts something new.
  final VoidCallback onPressed;

  final double size;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: label,
      // The circle and its text are one control: hiding the child's own label
      // stops a screen reader announcing "Workout" twice.
      excludeSemantics: true,
      child: Padding(
        // Lifts the circle above the bar's top edge without changing the bar's
        // height, so the raised button is never clipped. Sized to the sum of
        // the circle, the gap and the label, so the whole control sits inside
        // the bar's bounds rather than hanging below the screen edge.
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Material(
                color: scheme.primary,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onPressed,
                  // Matches the bar's press feedback so the button does not feel
                  // like it belongs to a different control set.
                  customBorder: const CircleBorder(),
                  child: Center(
                    child: SvgPicture.asset(
                      _dumbbellAsset,
                      // Recoloured rather than shipped at its authored fill, so
                      // the mark keeps contrast if the theme ever changes the
                      // primary colour. The asset itself is a plain white
                      // silhouette; this filter is what ties it to the scheme.
                      colorFilter: ColorFilter.mode(
                        scheme.onPrimary,
                        BlendMode.srcIn,
                      ),
                      width: size * 0.48,
                      height: size * 0.48,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            // Matches the bar's own label treatment so the action reads as
            // belonging to the same row rather than bolted onto it. Sized down
            // because it sits under a bigger element than the tab labels do.
            Text(
              label.toUpperCase(),
              style: context.text.labelCaps.copyWith(
                fontSize: 9,
                height: 12 / 9,
                letterSpacing: 0.5,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  /// The only vector asset in the app, kept in one place so the path is not
  /// repeated across the widgets that draw it.
  static const String _dumbbellAsset =
      'assets/images/dumbbell-large-minimalistic-svgrepo-com.svg';
}
