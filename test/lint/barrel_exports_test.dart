import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

List<String> _dartFiles(String root) {
  return Directory(root)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => p.normalize(file.path))
      .toList()
    ..sort();
}

void _expectExported({
  required String root,
  required String barrel,
  Set<String> excluded = const {},
}) {
  final source = File(barrel).readAsStringSync();
  final offenders = <String>[];
  for (final file in _dartFiles(root)) {
    if (file == p.normalize(barrel)) continue;
    final relative = p.relative(file, from: root);
    if (excluded.contains(relative)) continue;
    final export = "export '$relative';";
    if (!source.contains(export)) offenders.add(relative);
  }
  expect(
    offenders,
    isEmpty,
    reason:
        'Every component must be exported from its barrel.\n'
        'Missing from $barrel:\n${offenders.join('\n')}',
  );
}

void main() {
  test('lib/ui barrel exports every design-system file', () {
    _expectExported(root: 'lib/ui', barrel: 'lib/ui/ui.dart');
  });

  test('lib/widgets barrel exports every app widget', () {
    _expectExported(
      root: 'lib/widgets',
      barrel: 'lib/widgets/widgets.dart',
      excluded: {'notifications/notification_service.dart'},
    );
  });
}
