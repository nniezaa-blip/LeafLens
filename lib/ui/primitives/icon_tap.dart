import 'package:lextari/ui/ui.dart';

class IconTap extends StatelessWidget {
  const IconTap({required this.icon, required this.onPressed, super.key});
  final Widget icon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(padding: const EdgeInsets.all(8), child: icon),
    );
  }
}
