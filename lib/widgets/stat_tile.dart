import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A single figure in a bordered tile: a value, its label, and an optional
/// supporting line.
///
/// Used by the home screen's weekly summary and the profile's record grid, and
/// both need the same answer to "how big is this number next to its caption".
/// Hand-rolling that twice is how the two grids end up with different value
/// weights at the same nominal size, which is the kind of drift a reviewer
/// notices before they can say why it looks wrong.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.caption,
    this.emphasis = false,
  });

  final String value;

  /// Set above the value, so the tile reads as "8 sessions" rather than a
  /// bare number that has to be matched to its heading afterwards.
  final String label;

  final IconData? icon;

  /// Optional third line, used for context such as "3 of 8 done".
  final String? caption;

  /// Fills the tile with the primary container and flips the text colours, so
  /// the one number a screen most wants read first can win without changing
  /// its size.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final background = emphasis
        ? scheme.primaryContainer
        : scheme.surfaceContainerLowest;
    final valueColor = emphasis ? scheme.onPrimaryContainer : scheme.onSurface;
    final labelColor = emphasis
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.card,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: labelColor),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: context.text.labelCaps.copyWith(color: labelColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            // Scales down rather than clipping on a narrow screen or at a
            // large text scale, so a three-digit total stays readable in the
            // same tile a one-digit streak uses.
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: context.text.metric.copyWith(color: valueColor),
              maxLines: 1,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Text(
              caption!,
              style: textTheme.bodySmall?.copyWith(
                color: emphasis
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
