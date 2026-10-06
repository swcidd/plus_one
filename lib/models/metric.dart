import 'package:equatable/equatable.dart';

/// A single tracked figure on the dashboard or profile.
///
/// Carries both the raw numbers and the unit so the widget can lay the tile
/// out without parsing a pre-formatted string back apart.
class Metric extends Equatable {
  const Metric({
    required this.id,
    required this.label,
    required this.value,
    required this.unit,
    this.target,
  });

  final String id;
  final String label;
  final double value;
  final String unit;

  /// Upper bound for the day. Null for figures that are read once, such as
  /// resting heart rate, where a progress bar would be meaningless.
  final double? target;

  /// 0.0-1.0. Returns 0 when there is no target so callers can branch on
  /// `hasTarget` instead of duplicating the null check.
  double get progress {
    final upperBound = target;
    if (upperBound == null || upperBound <= 0) return 0;
    return (value / upperBound).clamp(0.0, 1.0);
  }

  bool get hasTarget => target != null;

  Metric copyWith({
    String? id,
    String? label,
    double? value,
    String? unit,
    double? target,
  }) {
    return Metric(
      id: id ?? this.id,
      label: label ?? this.label,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      target: target ?? this.target,
    );
  }

  /// "640" / "2.1" / "94.5K" / "92" - trailing zeros trimmed so the tile
  /// never shows "640.0", and totals from five digits up abbreviated so a
  /// lifetime figure does not push its label off a four-across cell.
  String get displayValue => _trim(value);

  /// "/800 kcal" for bounded metrics, just the unit otherwise. The tile sets
  /// [displayValue] large and this small, so the fraction reads as one
  /// number rather than two competing ones.
  String get displaySuffix => hasTarget ? '/${_trim(target!)} $unit' : unit;

  /// "of 800 kcal" for bounded metrics, "bpm" style suffix otherwise.
  String get displayRange {
    final upperBound = target;
    if (upperBound == null) return unit;
    return 'of ${_trim(upperBound)} $unit';
  }

  /// "640/800 kcal", or just the reading when there is no bound.
  String get displayAbsolute {
    final upperBound = target;
    if (upperBound == null) return '$displayValue $unit';
    return '$displayValue/${_trim(upperBound)} $unit';
  }

  static String _trim(double number) {
    if (number >= 10000) {
      final scaled = number / 1000;
      final text = scaled == scaled.roundToDouble()
          ? scaled.toStringAsFixed(0)
          : scaled.toStringAsFixed(1);
      return '${text.replaceFirst(RegExp(r'\.0$'), '')}K';
    }
    if (number == number.roundToDouble()) return number.toStringAsFixed(0);
    return number
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  factory Metric.fromJson(Map<String, dynamic> json) {
    return Metric(
      id: json['id'] as String,
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      target: (json['target'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'value': value,
    'unit': unit,
    'target': target,
  };

  @override
  List<Object?> get props => [id, label, value, unit, target];
}
