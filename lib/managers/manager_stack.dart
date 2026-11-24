import 'package:flutter/widgets.dart';

typedef ManagerBuilder = Widget Function(Widget child);

Widget buildManagerStack({
  required Widget child,
  required List<ManagerBuilder> managers,
}) {
  var current = child;
  for (final manager in managers.reversed) {
    current = manager(current);
  }
  return current;
}
