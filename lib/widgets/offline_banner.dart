import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lextari/features/auth/data/auth_session_manager.dart';

/// Banner shown at the top of the dashboard when the user is offline.
///
/// Hides when the auth state indicates a valid token is available.
class OfflineBanner extends ConsumerWidget {
  /// Creates an [OfflineBanner] widget.
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    if (session.value != null) return const SizedBox.shrink();
    if (session.isLoading) return const SizedBox.shrink();

    return MaterialBanner(
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      content: Row(
        children: [
          Icon(
            Icons.cloud_off,
            size: 16,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Text(
            'No connection — showing last known data',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
      actions: const [SizedBox.shrink()],
    );
  }
}
