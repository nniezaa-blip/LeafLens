import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onPressed,
    this.selected = false,
    this.radius = prism.AppCorner.lg,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onPressed;
  final bool selected;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return prism.Card(
      onPressed: onPressed,
      isSelected: selected,
      radius: radius,
      padding: padding,
      child: child,
    );
  }
}
