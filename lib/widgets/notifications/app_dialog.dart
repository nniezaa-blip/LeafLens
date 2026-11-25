import 'package:lextari/ui/ui.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmLabel = 'OK',
  String? cancelLabel,
  bool barrierDismissible = false,
  Widget? icon,
  VoidCallback? onConfirm,
  Color? confirmColor,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: title,
    barrierColor: AppColors.black.withValues(alpha: 0.35),
    pageBuilder: (dialogContext, _, _) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[icon, const SizedBox(height: 12)],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.offBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (cancelLabel != null)
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(cancelLabel),
                      ),
                    if (confirmLabel != null) ...[
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          onConfirm?.call();
                          Navigator.of(dialogContext).pop(true as T);
                        },
                        child: Text(confirmLabel),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
