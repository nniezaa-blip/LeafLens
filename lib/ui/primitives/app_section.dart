import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

class AppSection extends StatelessWidget {
  const AppSection({
    required this.title,
    required this.children,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        prism.ListHeader(title: title),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              subtitle!,
              style: prism.AppTextStyle.footnote.of(context).copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ...children,
      ],
    );
  }
}
