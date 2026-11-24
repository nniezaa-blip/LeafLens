import 'package:flutter/material.dart';

import 'package:lextari/features/dashboard/domain/growth_health_score.dart';

/// Small colored chip showing the health status label.
class StatusBadge extends StatelessWidget {
  /// Creates a [StatusBadge] for the given [status].
  const StatusBadge({required this.status, super.key});

  /// The health status to display (optimal, caution, danger, etc.).
  final HealthStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String get _label => switch (status) {
    HealthStatus.optimal => 'Optimal',
    HealthStatus.moderate => 'Moderate',
    HealthStatus.caution => 'Caution',
    HealthStatus.danger => 'Danger',
    HealthStatus.critical => 'Critical',
  };

  Color _color(BuildContext context) => switch (status) {
    HealthStatus.optimal => const Color(0xFF4CAF50),
    HealthStatus.moderate => const Color(0xFF8BC34A),
    HealthStatus.caution => const Color(0xFFFFC107),
    HealthStatus.danger => const Color(0xFFFF9800),
    HealthStatus.critical => Theme.of(context).colorScheme.error,
  };
}
