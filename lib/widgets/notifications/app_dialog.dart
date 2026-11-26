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
      final scheme = dialogContext.colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.dialogMaxWidth,
            ),
            child: Surface(
              color: scheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                side: BorderSide(color: scheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (icon != null) ...[
                      icon,
                      const SizedBox(height: AppSpacing.s12),
                    ],
                    Text(
                      title,
                      style: AppTextStyle.title3
                          .of(dialogContext, emphasized: true)
                          .copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      message,
                      style: AppTextStyle.subheadline
                          .of(dialogContext)
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (cancelLabel != null)
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(cancelLabel),
                          ),
                        if (confirmLabel != null) ...[
                          const SizedBox(width: AppSpacing.s8),
                          FilledButton(
                            style: confirmColor == null
                                ? null
                                : ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      confirmColor,
                                    ),
                                  ),
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
          ),
        ),
      );
    },
  );
}
