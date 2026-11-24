import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.trailing,
    this.leading,
    super.key,
  });

  final Widget body;
  final String? title;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final bar = prism.ScaffoldBar(
      isCompact: false,
      listenable: const _EmptyListenable(),
      loading: const _FalseValueListenable(),
      builder: (context) {
        return SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (leading != null) leading!,
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: prism.AppTextStyle.title1.of(context),
                    ),
                  )
                else
                  const Spacer(),
                ?trailing,
              ],
            ),
          ),
        );
      },
    );
    return prism.PrismScaffold(bar: bar, body: body);
  }
}

class _EmptyListenable implements Listenable {
  const _EmptyListenable();
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
}

class _FalseValueListenable extends ValueListenable<bool> {
  const _FalseValueListenable();
  @override
  bool get value => false;
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
}
