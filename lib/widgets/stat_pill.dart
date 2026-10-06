import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// One figure with an optional icon, used wherever a screen needs to show a
/// count without committing a whole card to it.
///
/// `filled` switches between the chip form (dashboard stat rows) and the bare
/// form (calendar summary strip). Two appearances from one widget keeps the
/// icon size, number weight and label tracking identical in both places,
/// which is the part that usually drifts when each screen hand-rolls its own.
class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.value,
    this.label,
    this.icon,
    this.filled = true,
  });

  final String value;
  final String? label;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 5),
        ],
        Text(
          value.toUpperCase(),
          style: context.text.labelCaps.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (label != null)
          Text(' ${label!.toUpperCase()}', style: context.text.labelCaps),
      ],
    );

    if (!filled) return content;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: AppRadius.tag,
      ),
      child: content,
    );
  }
}
