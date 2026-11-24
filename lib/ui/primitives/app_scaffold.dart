import 'package:lextari/ui/ui.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.body, this.bar, super.key});
  final Widget body;
  final PreferredSizeWidget? bar;

  @override
  Widget build(BuildContext context) {
    return PrismScaffold(bar: bar ?? const EmptyBar(), body: body);
  }
}
