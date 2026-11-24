import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

class AppListItem extends StatelessWidget {
  const AppListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return prism.DecorationListItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onPressed: onTap,
    );
  }
}
