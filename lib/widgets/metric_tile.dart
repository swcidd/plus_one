import 'package:flutter/material.dart';

import '../models/metric.dart';
import '../theme/app_typography.dart';
import 'progress_bar.dart';

/// One tracked figure rendered as a card.
///
/// The unit sits on its own line under the number rather than beside it.
/// Sideways, "74.5" plus " KG" clips as soon as a grid drops below roughly
/// 100dp, which is exactly what the four-across biometric row does.
///
/// `compact` swaps the 36pt metric face for the 20pt one so the same widget
/// works in a two-across dashboard row and a four-across telemetry strip.
class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.metric, this.compact = false});

  final Metric metric;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final numberStyle = compact ? context.text.metric : context.text.dataMetric;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.label.toUpperCase(),
            style: context.text.labelCaps,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            metric.displayValue,
            style: numberStyle,
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
          const SizedBox(height: 2),
          Text(
            metric.hasTarget ? metric.displayRange.toUpperCase() : metric.unit,
            style: textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (metric.hasTarget) ...[
            const SizedBox(height: 10),
            ProgressBar(value: metric.progress, height: compact ? 3 : 4),
          ],
        ],
      ),
    );
  }
}
