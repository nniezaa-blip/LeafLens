import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lextari/features/settings/presentation/settings_screen.dart';
import 'package:lextari/features/stats/presentation/stats_screen.dart';
import 'package:lextari/shared/widgets/background_ellipse.dart';

/// App-level shell wrapping dashboard tabs with persistent green background,
/// ellipse, floating bottom nav bar, and draggable carousel.
///
/// The carousel tracks the user's finger during horizontal drags and settles
/// to the nearest tab on release. Nav bar taps trigger the same slide
/// animation via `_handleNavTap`.
class DashboardShell extends StatefulWidget {
  /// Creates a [DashboardShell] backed by [StatefulNavigationShell].
  const DashboardShell({
    required this.navigationShell,
    super.key,
  });

  /// The [StatefulNavigationShell] managing branch navigation and state.
  final StatefulNavigationShell navigationShell;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Pixel offset from resting position. Driven by finger during drag,
  /// driven by [_controller] via [_settleTween] after release.
  double _dragOffset = 0;

  /// Whether a drag gesture is active or settling.
  bool _isDragActive = false;

  /// Whether the drag direction has been locked to horizontal.
  bool _dragDirectionLocked = false;

  /// X coordinate where the drag started.
  double _dragStartDx = 0;

  bool _isForward = true;
  int _previousIndex = 0;

  /// Exact branch index requested by a nav-bar tap, if any.
  ///
  /// When set, the slide animation and commit land on this index rather than
  /// the adjacent index derived from the drag direction.
  int? _tapTargetIndex;

  /// Active settle tween — non-null while the settle animation is running.
  Tween<double>? _settleTween;

  /// Fraction of screen width required to trigger a tab switch on release.
  static const _snapThreshold = 0.35;

  /// Rubber-band dampening factor when dragging past the edge.
  static const _edgeDampening = 0.3;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.navigationShell.currentIndex;
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 280),
          )
          ..addListener(_onControllerTick)
          ..addStatusListener(_onControllerStatus);
  }

  @override
  void didUpdateWidget(DashboardShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = widget.navigationShell.currentIndex;
    if (newIndex != _previousIndex && !_isDragActive) {
      _isForward = newIndex > _previousIndex;
      _previousIndex = newIndex;
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerTick)
      ..removeStatusListener(_onControllerStatus)
      ..dispose();
    super.dispose();
  }

  /// Index of the trends tab, whose charts consume horizontal drags so the
  /// carousel swipe is disabled there to let users pan the charts instead.
  static const _statsIndex = 1;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final swipeEnabled = widget.navigationShell.currentIndex != _statsIndex;

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundEllipse(),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: swipeEnabled ? _handleDragStart : null,
            onHorizontalDragUpdate: swipeEnabled ? _handleDragUpdate : null,
            onHorizontalDragEnd: swipeEnabled ? _handleDragEnd : null,
            child: SafeArea(child: _buildAnimatedChild()),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: bottomPadding + 18,
            child: _FloatingNavBar(
              navigationShell: widget.navigationShell,
              dragOffset: _dragOffset,
              isDragActive: _isDragActive,
              onTabTap: _handleNavTap,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // Animation
  // -----------------------------------------------------------

  Widget _buildAnimatedChild() {
    if (_dragOffset == 0 && !_isDragActive) {
      return widget.navigationShell;
    }

    final screenW = MediaQuery.of(context).size.width;
    final canNavigate = _isForward
        ? widget.navigationShell.currentIndex < 2
        : widget.navigationShell.currentIndex > 0;

    if (!canNavigate) {
      return Transform.translate(
        offset: Offset(_dragOffset, 0),
        child: _pageForIndex(_previousIndex),
      );
    }

    final enteringOffset = _isForward
        ? Offset(screenW + _dragOffset, 0)
        : Offset(-screenW + _dragOffset, 0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Transform.translate(
          offset: Offset(_dragOffset, 0),
          child: _pageForIndex(_previousIndex),
        ),
        Transform.translate(
          offset: enteringOffset,
          child: _pageForIndex(_incomingIndex),
        ),
      ],
    );
  }

  /// Index of the page sliding in during the current transition.
  int get _incomingIndex =>
      _tapTargetIndex ?? (_isForward ? _previousIndex + 1 : _previousIndex - 1);

  void _onControllerTick() {
    final tween = _settleTween;
    if (tween != null) {
      setState(() => _dragOffset = tween.transform(_controller.value));
    }
  }

  void _onControllerStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    if (_dragOffset.abs() > 0.5) {
      _commitTabSwitch();
    } else {
      _isDragActive = false;
    }
    _settleTween = null;
  }

  // -----------------------------------------------------------
  // Drag gesture
  // -----------------------------------------------------------

  void _handleDragStart(DragStartDetails details) {
    _isDragActive = true;
    _dragDirectionLocked = false;
    _dragStartDx = details.localPosition.dx;
    _tapTargetIndex = null;
    _controller.stop();
    _settleTween = null;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.localPosition.dx - _dragStartDx;

    if (!_dragDirectionLocked) {
      if (delta.abs() < 8) return;
      _dragDirectionLocked = true;
    }

    final screenW = MediaQuery.of(context).size.width;
    setState(() {
      _dragOffset = _clampDrag(delta, screenW);
      _isForward = _dragOffset < 0;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragDirectionLocked) {
      _isDragActive = false;
      return;
    }

    final screenW = MediaQuery.of(context).size.width;
    final velocity = details.primaryVelocity ?? 0;

    _isForward = _dragOffset < 0;

    final positionTriggered = _dragOffset.abs() > screenW * _snapThreshold;
    final velocityTriggered = velocity.abs() > 800;
    final canNavigate = _isForward
        ? widget.navigationShell.currentIndex < 2
        : widget.navigationShell.currentIndex > 0;

    if ((positionTriggered || velocityTriggered) && canNavigate) {
      _settleToEdge(screenW);
    } else {
      _settleToOrigin();
    }
  }

  double _clampDrag(double rawOffset, double screenW) {
    final idx = widget.navigationShell.currentIndex;
    if (rawOffset < 0 && idx >= 2) return rawOffset * _edgeDampening;
    if (rawOffset > 0 && idx <= 0) return rawOffset * _edgeDampening;
    return rawOffset;
  }

  // -----------------------------------------------------------
  // Settle animation
  // -----------------------------------------------------------

  void _settleToEdge(double screenW) {
    final target = _isForward ? -screenW : screenW;
    _settleTween = Tween<double>(begin: _dragOffset, end: target);
    _controller
      ..stop()
      ..reset();
    unawaited(_controller.forward());
  }

  void _settleToOrigin() {
    _settleTween = Tween<double>(begin: _dragOffset, end: 0);
    _controller
      ..stop()
      ..reset();
    unawaited(_controller.forward());
  }

  void _commitTabSwitch() {
    final newIndex = _incomingIndex;

    widget.navigationShell.goBranch(newIndex);

    setState(() {
      _previousIndex = newIndex;
      _dragOffset = 0;
      _isDragActive = false;
      _tapTargetIndex = null;
    });
  }

  // -----------------------------------------------------------
  // Tap path
  // -----------------------------------------------------------

  void _handleNavTap(int targetIndex) {
    final currentIndex = widget.navigationShell.currentIndex;
    if (targetIndex == currentIndex) return;

    _isForward = targetIndex > currentIndex;
    _previousIndex = currentIndex;
    _tapTargetIndex = targetIndex;
    _dragOffset = 0;
    _isDragActive = true;

    final screenW = MediaQuery.of(context).size.width;
    _settleToEdge(screenW);
  }

  // -----------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------

  static Widget _pageForIndex(int index) {
    switch (index) {
      case 1:
        return const StatsScreen();
      case 2:
        return const SettingsScreen();
      default:
        return const DashboardScreen();
    }
  }
}

//
// Private widgets
//

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.navigationShell,
    required this.dragOffset,
    required this.isDragActive,
    required this.onTabTap,
  });

  final StatefulNavigationShell navigationShell;
  final double dragOffset;
  final bool isDragActive;
  final ValueChanged<int> onTabTap;

  static const _itemWidth = 62.0;
  static const _itemCount = 3;
  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.bar_chart_rounded,
    Icons.settings_rounded,
  ];

  int get _activeIndex => navigationShell.currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.navBarBackground,
        borderRadius: BorderRadius.circular(50),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const totalItemWidth = _itemWidth * _itemCount;
          final gap =
              (constraints.maxWidth - totalItemWidth) / (_itemCount + 1);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              _ActiveIndicator(
                gap: gap,
                activeIndex: _activeIndex,
                dragOffset: dragOffset,
                isDragActive: isDragActive,
                itemWidth: _itemWidth,
                screenWidth: constraints.maxWidth,
              ),
              for (var i = 0; i < _itemCount; i++)
                _NavIcon(
                  index: i,
                  gap: gap,
                  icon: _icons[i],
                  itemWidth: _itemWidth,
                  onTap: () => onTabTap(i),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ActiveIndicator extends StatelessWidget {
  const _ActiveIndicator({
    required this.gap,
    required this.activeIndex,
    required this.dragOffset,
    required this.isDragActive,
    required this.itemWidth,
    required this.screenWidth,
  });

  final double gap;
  final int activeIndex;
  final double dragOffset;
  final bool isDragActive;
  final double itemWidth;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final targetX = _computeTargetX();

    if (!isDragActive) {
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        left: targetX,
        top: (80 - itemWidth) / 2,
        width: itemWidth,
        height: itemWidth,
        child: _IndicatorDecoration(itemWidth: itemWidth),
      );
    }

    return Positioned(
      left: targetX,
      top: (80 - itemWidth) / 2,
      width: itemWidth,
      height: itemWidth,
      child: _IndicatorDecoration(itemWidth: itemWidth),
    );
  }

  double _computeTargetX() {
    final baseX = gap + activeIndex * (gap + itemWidth);
    if (!isDragActive || screenWidth == 0) return baseX;

    final progress = (dragOffset / screenWidth).clamp(-1.0, 1.0);
    final step = gap + itemWidth;
    return baseX - progress * step;
  }
}

class _IndicatorDecoration extends StatelessWidget {
  const _IndicatorDecoration({required this.itemWidth});

  final double itemWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.index,
    required this.gap,
    required this.icon,
    required this.itemWidth,
    required this.onTap,
  });

  final int index;
  final double gap;
  final IconData icon;
  final double itemWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: gap + index * (gap + itemWidth),
      top: (80 - itemWidth) / 2,
      width: itemWidth,
      height: itemWidth,
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Icon(
            icon,
            size: 28,
            color: AppColors.offBlack,
          ),
        ),
      ),
    );
  }
}
