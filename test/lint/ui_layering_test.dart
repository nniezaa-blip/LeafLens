import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

final _directive = RegExp(
  r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

const _forbiddenPackages = <String>[
  'package:flutter_riverpod/',
  'package:riverpod/',
  'package:riverpod_annotation/',
  'package:hooks_riverpod/',
];

String _resolve(String uri, String from) {
  if (uri.startsWith('package:lextari/')) {
    return 'lib/${uri.substring('package:lextari/'.length)}';
  }
  if (uri.startsWith('dart:') || uri.startsWith('package:')) return uri;
  return p.normalize(p.join(p.dirname(from), uri));
}

bool _isForbiddenPackage(String uri) =>
    _forbiddenPackages.any((package) => uri.startsWith(package));

bool _staysInPureUi(String path) {
  if (!path.startsWith('lib/')) return true;
  return path.startsWith('lib/ui/');
}

List<String>? _escape(String root) {
  final parents = <String, String>{};
  final queue = <String>[root];
  final seen = <String>{root};
  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    final file = File(current);
    if (!file.existsSync()) continue;
    for (final match in _directive.allMatches(file.readAsStringSync())) {
      final next = _resolve(match.group(1)!, current);
      if (!seen.add(next)) continue;
      parents[next] = current;
      if (!_staysInPureUi(next) || _isForbiddenPackage(next)) {
        final chain = <String>[next];
        var cursor = next;
        while (parents.containsKey(cursor)) {
          cursor = parents[cursor]!;
          chain.insert(0, cursor);
        }
        return chain;
      }
      if (next.startsWith('lib/')) queue.add(next);
    }
  }
  return null;
}

void main() {
  test('lib/ui stays pure and has no app/state dependencies', () {
    final directory = Directory('lib/ui');
    final offenders = <String>[];
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final relativePath = p.relative(entity.path);
      final chain = _escape(relativePath);
      if (chain != null) offenders.add(chain.join(' -> '));
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'lib/ui is the pure design system. It may only depend on Flutter, '
          'prism_ui, and files inside lib/ui.\n${offenders.join('\n')}',
    );
  });
}
