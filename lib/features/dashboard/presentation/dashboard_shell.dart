import 'package:go_router/go_router.dart';
import 'package:lextari/ui/ui.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  int _previousIndex = 0;
  bool _isForward = true;

  static const _destinations = [
    NavigationDockDestination(glyph: AppGlyphs.sprout, label: 'Home'),
    NavigationDockDestination(glyph: AppGlyphs.barChart, label: 'Stats'),
    NavigationDockDestination(glyph: AppGlyphs.settings, label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.navigationShell.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: AppMotionTokens.fast,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.settle,
    );
    _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant DashboardShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.navigationShell.currentIndex;
    if (next != _previousIndex) {
      _isForward = next > _previousIndex;
      _previousIndex = next;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == widget.navigationShell.currentIndex) return;
    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final bottomInset = NavigationDock.insetOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        const BotanicalBackground(),
        BottomInsetScope(
          inset: bottomInset,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animation,
              child: widget.navigationShell,
              builder: (context, child) {
                final progress = _animation.value;
                final shift =
                    (1 - progress) * _tabSwitchOffset * (_isForward ? 1 : -1);
                return Transform.translate(
                  offset: Offset(shift, 0),
                  child: child,
                );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: NavigationDock(
            destinations: _destinations,
            selectedIndex: currentIndex,
            onSelected: _handleTap,
          ),
        ),
      ],
    );
  }

  static const double _tabSwitchOffset = AppSpacing.s12;
}
