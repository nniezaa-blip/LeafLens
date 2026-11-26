import 'package:go_router/go_router.dart';
import 'package:lextari/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lextari/features/settings/presentation/settings_screen.dart';
import 'package:lextari/features/stats/presentation/stats_screen.dart';
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
  late Animation<double> _animation;
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
      duration: const Duration(milliseconds: 320),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
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

  Widget _pageForIndex(int index) {
    return switch (index) {
      1 => const StatsScreen(),
      2 => const SettingsScreen(),
      _ => const DashboardScreen(),
    };
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
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              final t = _animation.value;
              final enteringOffset = Offset(
                (_isForward ? 1 : -1) * (1 - t) * 0.08,
                0,
              );
              final leavingOffset = Offset(
                (_isForward ? -1 : 1) * t * 0.03,
                0,
              );
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (t < 1)
                    FractionalTranslation(
                      translation: leavingOffset,
                      child: Opacity(
                        opacity: 1 - t,
                        child: IgnorePointer(
                          child: _pageForIndex(
                            _previousIndex == currentIndex
                                ? currentIndex
                                : (_isForward
                                      ? currentIndex - 1
                                      : currentIndex + 1),
                          ),
                        ),
                      ),
                    ),
                  FractionalTranslation(
                    translation: t < 1 ? enteringOffset : Offset.zero,
                    child: Opacity(
                      opacity: t.clamp(0.0, 1.0),
                      child: widget.navigationShell,
                    ),
                  ),
                ],
              );
            },
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
}
