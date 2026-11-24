import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';

class AppManager extends ConsumerStatefulWidget {
  const AppManager({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppManager> createState() => _AppManagerState();
}

class _AppManagerState extends ConsumerState<AppManager> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(authSessionProvider);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
