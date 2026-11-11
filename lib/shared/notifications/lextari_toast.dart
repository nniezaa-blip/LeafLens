import 'package:flutter/material.dart';

import 'package:lextari/core/theme/app_colors.dart';
import 'package:toastification/toastification.dart';

/// Lextari branded toast widget.
///
/// Passed as the builder to toastification.showCustom via
/// NotificationService. Renders a white card with a 4px coloured
/// left accent bar, icon, title + description, and a close button.
class LextariToast extends StatelessWidget {
  /// Creates a [LextariToast] with the given display properties.
  const LextariToast({
    required this.holder,
    required this.title,
    required this.type,
    this.description,
    super.key,
  });

  /// Lifecycle token returned by [Toastification.showCustom].
  final ToastificationItem holder;

  /// Primary message text.
  final String title;

  /// Determines colour and icon.
  final ToastificationType type;

  /// Optional supporting detail.
  final String? description;

  @override
  Widget build(BuildContext context) {
    final accent = _colour(type);
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _AccentBar(colour: accent),
              const SizedBox(width: 12),
              _ToastIcon(icon: _icon(type), colour: accent),
              const SizedBox(width: 10),
              _ToastContent(title: title, description: description),
              _ToastCloseButton(holder: holder),
            ],
          ),
        ),
      ),
    );
  }

  // ── Type helpers ─────────────────────────────────────────

  static Color _colour(ToastificationType type) {
    if (type == ToastificationType.success) return AppColors.mediumGreen;
    if (type == ToastificationType.error) return AppColors.redAlert;
    if (type == ToastificationType.warning) return AppColors.yellowAlert;
    return AppColors.chartBlue;
  }

  static IconData _icon(ToastificationType type) {
    if (type == ToastificationType.success) return Icons.check_circle_rounded;
    if (type == ToastificationType.error) return Icons.error_rounded;
    if (type == ToastificationType.warning) return Icons.warning_rounded;
    return Icons.info_rounded;
  }
}

//
// Private widgets
//

/// 4px coloured bar on the left edge of the toast.
class _AccentBar extends StatelessWidget {
  const _AccentBar({required this.colour});
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: colour,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
    );
  }
}

/// Type icon with matching colour.
class _ToastIcon extends StatelessWidget {
  const _ToastIcon({required this.icon, required this.colour});
  final IconData icon;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Icon(icon, color: colour, size: 20),
    );
  }
}

/// Title and optional description stacked vertically.
class _ToastContent extends StatelessWidget {
  const _ToastContent({required this.title, this.description});
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.offBlack,
                height: 1.3,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 2),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dismiss button on the right edge.
class _ToastCloseButton extends StatelessWidget {
  const _ToastCloseButton({required this.holder});
  final ToastificationItem holder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.close_rounded, size: 18),
          color: AppColors.mediumGrey,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          onPressed: () => Toastification().dismiss(holder),
        ),
      ),
    );
  }
}
