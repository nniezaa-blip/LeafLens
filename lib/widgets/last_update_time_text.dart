import 'package:flutter/widgets.dart';
import 'package:lextari/widgets/active_polling.dart';

/// A relative label for the last successful update.
String formatLastUpdate(DateTime date, {bool compact = false}) {
  final age = DateTime.now().difference(date);
  if (age.inMinutes < 1) return 'just now';
  if (age.inMinutes < 60) {
    return compact ? '${age.inMinutes}m' : '${age.inMinutes}m ago';
  }
  if (age.inHours < 24) {
    return compact ? '${age.inHours}h' : '${age.inHours}h ago';
  }
  return compact ? '${age.inDays}d' : '${age.inDays}d ago';
}

/// Shows how long ago [lastUpdateDate] was, refreshed once a minute.
class LastUpdateTimeText extends StatelessWidget {
  /// Creates a [LastUpdateTimeText].
  const LastUpdateTimeText({
    required this.lastUpdateDate,
    this.style,
    this.compact = false,
    super.key,
  });

  /// The last update time, or null to show nothing.
  final DateTime? lastUpdateDate;

  /// Optional text style.
  final TextStyle? style;

  /// Uses short labels such as `5m`.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final lastUpdateDate = this.lastUpdateDate;
    if (lastUpdateDate == null) {
      return Text('', style: style);
    }
    return TickBuilder(
      duration: const Duration(minutes: 1),
      builder: (context, _) => Text(
        formatLastUpdate(lastUpdateDate, compact: compact),
        style: style,
      ),
    );
  }
}
