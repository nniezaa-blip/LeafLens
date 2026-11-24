import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';
import 'package:lextari/features/dashboard/providers/dashboard_bootstrap_provider.dart';

class DashboardManager extends ConsumerWidget {
  const DashboardManager({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).value;
    if (session != null) {
      ref.watch(dashboardBootstrapProvider);
    }
    return child;
  }
}
