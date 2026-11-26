import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:lextari/ui/tokens/app_tokens.dart';
import 'package:prism_ui/prism_ui.dart';

/// Pull-to-refresh with the same motion as AISolutions-RN.
///
/// The indicator follows the pull, fades and scales in after the first few
/// pixels, then springs to the threshold while [onRefresh] runs. Releasing
/// before the threshold settles it back to rest.
class PullToRefresh extends StatefulWidget {
  /// Creates a [PullToRefresh].
  const PullToRefresh({
    required this.onRefresh,
    required this.child,
    super.key,
    this.threshold = AppSizes.refreshThreshold,
    this.useGesture = false,
  });

  /// Runs while the indicator is held at the threshold.
  final Future<void> Function() onRefresh;

  /// Scrollable content under the indicator.
  final Widget child;

  /// Pull distance that arms the refresh.
  final double threshold;

  /// Uses a vertical drag gesture instead of scroll notifications.
  ///
  /// Pages that are not scrollable (a full-height chart) still need the
  /// gesture; scrollable pages send notifications.
  final bool useGesture;

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh>
    with SingleTickerProviderStateMixin {
  static const double _maxPullFactor = 1.4;
  static const double _spinnerTravelRatio = 0.32;
  static const double _restingScale = 0.72;
  static const double _fadeInStart = 0.08;
  static const double _fadeInEnd = 0.55;

  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: AppMotionTokens.refreshSettle,
  );
  Animation<double>? _settleAnimation;
  double _pull = 0;
  bool _dragging = false;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _settle.addListener(_followSettle);
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  void _followSettle() {
    final animation = _settleAnimation;
    if (animation == null) return;
    setState(() => _pull = animation.value);
  }

  void _setPull(double value) {
    final next = value.clamp(0.0, widget.threshold * _maxPullFactor);
    if (next == _pull) return;
    setState(() => _pull = next);
  }

  void _animatePullTo(double target, Duration duration) {
    _settle.duration = duration;
    _settleAnimation = Tween<double>(begin: _pull, end: target).animate(
      CurvedAnimation(parent: _settle, curve: AppCurves.settle),
    );
    _settle.forward(from: 0);
  }

  Future<void> _startRefresh() async {
    setState(() => _refreshing = true);
    _animatePullTo(widget.threshold, AppMotionTokens.refreshSnap);
    try {
      await widget.onRefresh();
    } on Object {
      // The refresh owns its error reporting; the indicator still resets.
    } finally {
      if (mounted) {
        setState(() => _refreshing = false);
        _animatePullTo(0, AppMotionTokens.refreshSettle);
      }
    }
  }

  void _handleDragStart(DragStartDetails details) {
    if (_refreshing) return;
    _settle.stop();
    _dragging = true;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragging || _refreshing) return;
    final delta = details.delta.dy;
    if (delta <= 0) {
      _setPull(0);
      return;
    }
    _setPull(_pull + delta);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;
    if (_pull >= widget.threshold && !_refreshing) {
      unawaited(_startRefresh());
    } else {
      _animatePullTo(0, AppMotionTokens.refreshSettle);
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axisDirection != AxisDirection.down) return false;

    if (notification is ScrollStartNotification &&
        notification.dragDetails != null &&
        metrics.extentBefore == 0) {
      _settle.stop();
      _dragging = true;
    } else if (notification is OverscrollNotification && _dragging) {
      _setPull(_pull - notification.overscroll);
    } else if (notification is ScrollUpdateNotification && _dragging) {
      final delta = notification.scrollDelta;
      if (delta != null && metrics.extentBefore == 0) {
        _setPull(_pull - delta);
      }
    } else if (notification is ScrollEndNotification && _dragging) {
      _dragging = false;
      if (_pull >= widget.threshold && !_refreshing) {
        unawaited(_startRefresh());
      } else {
        _animatePullTo(0, AppMotionTokens.refreshSettle);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.threshold == 0)
        ? 0.0
        : (_pull / widget.threshold).clamp(0.0, 1.0);
    final opacity = _refreshing
        ? 1.0
        : ((progress - _fadeInStart) / (_fadeInEnd - _fadeInStart)).clamp(
            0.0,
            1.0,
          );
    final scale = _refreshing
        ? 1.0
        : _restingScale + (1 - _restingScale) * progress;
    final top =
        context.appBarInset + AppSpacing.s8 + _pull * _spinnerTravelRatio;

    final body = Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (widget.useGesture)
          Positioned(
            top: context.appBarInset,
            left: 0,
            right: 0,
            height: AppSizes.pullGestureHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: _handleDragStart,
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              child: const SizedBox.expand(),
            ),
          ),
        if (opacity > 0)
          Positioned(
            top: top,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Center(
                    child: ActivityIndicator(
                      size: AppSizes.spinner,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    if (widget.useGesture) return body;
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: body,
    );
  }
}
