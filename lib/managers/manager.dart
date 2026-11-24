import 'package:flutter/widgets.dart';

typedef ManagerChildBuilder = Widget Function(Widget child);

abstract class AppChildManager extends StatelessWidget {
  const AppChildManager({required this.child, super.key});

  final Widget child;
}
