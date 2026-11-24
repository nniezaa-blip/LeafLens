import 'package:flutter/material.dart';

/// Wraps a child widget and catches build errors, showing a fallback
/// instead of crashing the whole screen.
///
/// Each sensor tile/chart gets its own boundary so one failure
/// doesn't cascade to the rest of the dashboard.
class SensorErrorBoundary extends StatefulWidget {
  /// Creates a [SensorErrorBoundary] wrapping [child], labelled with [label]
  /// for the fallback message.
  const SensorErrorBoundary({
    required this.label,
    required this.child,
    super.key,
  });

  /// Human-readable label shown in the fallback UI (e.g. "Soil Moisture").
  final String label;

  /// The widget to wrap with error-catching behaviour.
  final Widget child;

  @override
  State<SensorErrorBoundary> createState() => _SensorErrorBoundaryState();
}

class _SensorErrorBoundaryState extends State<SensorErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      final cs = Theme.of(context).colorScheme;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.error.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sensors_off, color: cs.error, size: 24),
            const SizedBox(height: 4),
            Text(
              '${widget.label} unavailable',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onErrorContainer),
            ),
            TextButton(
              onPressed: () => setState(() => _error = null),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return _ErrorCapture(
      onError: (e) => setState(() => _error = e),
      child: widget.child,
    );
  }
}

class _ErrorCapture extends StatefulWidget {
  const _ErrorCapture({required this.child, required this.onError});
  final Widget child;
  final void Function(Object) onError;

  @override
  State<_ErrorCapture> createState() => _ErrorCaptureState();
}

class _ErrorCaptureState extends State<_ErrorCapture> {
  @override
  void initState() {
    super.initState();
    // FlutterError.onError catches widget build errors.
    FlutterError.onError = (details) {
      widget.onError(details.exception);
    };
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
