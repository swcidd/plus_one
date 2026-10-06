import 'package:flutter/material.dart';

import '../models/metric.dart';
import '../theme/app_typography.dart';
import 'progress_bar.dart';

/// One tracked figure rendered as a card.
///
/// `compact` swaps the 36pt metric face for the 20pt one so the same widget
/// can sit in a three-across row on the dashboard and a two-across row
/// underneath without the number colliding with its unit.
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  metric.displayValue,
                  style: numberStyle,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                metric.displaySuffix,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
