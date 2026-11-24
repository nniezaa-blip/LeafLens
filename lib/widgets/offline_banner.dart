import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';
import 'package:lextari/ui/ui.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).value;
    if (session != null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: AppColors.yellowAlert.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const GlyphIcon(AppGlyphs.cloudOff, size: 18, color: AppColors.darkGrey),
          const SizedBox(width: 8),
          Text(
            'No connection — showing last known data',
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12, color: AppColors.darkGrey),
          ),
        ],
      ),
    );
  }
}
