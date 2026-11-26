import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// Maps a round-trip delay to a status colour.
extension DelayColorScheme on ColorScheme {
  /// Returns a status colour for [delayMilliseconds].
  ///
  /// Negative delays are errors, sub-600 ms is healthy and the rest is a
  /// warning. A null delay has no colour.
  Color? delayColor(int? delayMilliseconds) {
    if (delayMilliseconds == null) return null;
    if (delayMilliseconds < 0) return error;
    if (delayMilliseconds < 600) return success;
    return warning;
  }
}
