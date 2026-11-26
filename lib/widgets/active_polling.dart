import 'dart:async';

import 'package:flutter/widgets.dart';

/// Builds a widget with a counter that advances every [duration].
///
/// Used for relative timestamps and other values that need to refresh while a
/// page is on screen without polling the network.
class TickBuilder extends StatefulWidget {
  /// Creates a [TickBuilder].
  const TickBuilder({
    required this.duration,
    required this.builder,
    super.key,
  }) : assert(duration > Duration.zero, 'duration must be positive');

  /// How often the builder refreshes.
  final Duration duration;

  /// Builds with the current tick.
  final Widget Function(BuildContext context, int tick) builder;

  @override
  State<TickBuilder> createState() => _TickBuilderState();
}

class _TickBuilderState extends State<TickBuilder> with WidgetsBindingObserver {
  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant TickBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration == widget.duration) return;
    _startTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(widget.duration, (_) {
      if (!mounted) return;
      setState(() => _tick++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _tick);
  }
}
