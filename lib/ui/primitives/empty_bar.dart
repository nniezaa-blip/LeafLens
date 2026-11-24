import 'package:lextari/ui/ui.dart';

class EmptyBar extends StatelessWidget implements PreferredSizeWidget {
  const EmptyBar({super.key});
  @override
  Size get preferredSize => Size.zero;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
