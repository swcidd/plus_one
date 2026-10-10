import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The centred action button in the destination bar.
///
/// Sits between the tabs and reads as a different kind of control: a filled
/// circle on the bar's surface, where every other destination is an unboxed
/// icon and label. The contrast is the point - "start a workout" is the one
/// thing a lifter opens the app to do, and a row of four identical icons would
/// bury it at the same weight as "browse exercises".
///
/// Raises out of the bar rather than sitting flush in it so it reads as an
/// action on the bar rather than a fifth place to go.
class WorkoutActionButton extends StatelessWidget {
  const WorkoutActionButton({
    super.key,
    required this.onPressed,
    this.size = 56,
  });

  /// Opening a session. The button owns no state of its own, so what happens
  /// afterwards is the caller's decision - the bar does not know whether this
  /// resumes today's plan or starts something new.
  final VoidCallback onPressed;

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Start a workout',
      // The circle is a visual container, not a control boundary; the tappable
      // area is the whole elevated button including its invisible padding.
      child: Padding(
        // Lifts the circle above the bar's top edge without changing the bar's
        // height, so the raised button is never clipped. Sized rather than
        // offset because a Stack aligns its children by position, not by
        // padding, and padding is what keeps the circle inside the bar's own
        // bounds for hit testing.
        padding: const EdgeInsets.only(top: 18),
        child: SizedBox(
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
                  // Recoloured rather than shipped as a fixed dark ink: the
                  // file's own fill is near-black, which would vanish against
                  // the primary container in dark mode.
                  colorFilter: ColorFilter.mode(
                    scheme.onPrimary,
                    BlendMode.srcIn,
                  ),
                  width: size * 0.5,
                  height: size * 0.5,
                  semanticsLabel: 'Dumbbell',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The only vector asset in the app, kept in one place so the path is not
  /// repeated across the widgets that draw it.
  static const String _dumbbellAsset =
      'assets/images/dumbbell-large-minimalistic-svgrepo-com.svg';
}
