import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

final _importPattern = RegExp(
  r'''^\s*import\s+['"]([^'"]+)['"];''',
  multiLine: true,
);

String? _resolveLocal(String uri) {
  if (uri.startsWith('package:lextari/')) {
    return 'lib/${uri.substring('package:lextari/'.length)}';
  }
  return null;
}

List<String> _dartFiles(String root) {
  final directory = Directory(root);
  if (!directory.existsSync()) return <String>[];
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => p.normalize(file.path))
      .toList()
    ..sort();
}

List<String> _imports(String path) {
  final content = File(path).readAsStringSync();
  return _importPattern
      .allMatches(content)
      .map((match) => match.group(1)!)
      .toList();
}

void _expectNoForbiddenImports({
  required Iterable<String> roots,
  required bool Function(String filePath, String importPath) isForbidden,
  required String reason,
}) {
  final offenders = <String>[];
  for (final root in roots) {
    for (final file in _dartFiles(root)) {
      for (final uri in _imports(file)) {
        final local = _resolveLocal(uri);
        if (local == null) continue;
        if (isForbidden(file, local)) {
          offenders.add('$file -> $local');
        }
      }
    }
  }
  expect(offenders, isEmpty, reason: reason);
}

void main() {
  test('presentation does not import data implementations directly', () {
    _expectNoForbiddenImports(
      roots: const ['lib/features'],
      isForbidden: (file, path) =>
          file.contains('/presentation/') && path.contains('/data/'),
      reason:
          'Presentation should read state via providers/domain interfaces, '
          'not data layer implementations.',
    );
  });

  test('domain layer is framework and implementation agnostic', () {
    _expectNoForbiddenImports(
      roots: const ['lib/features'],
      isForbidden: (file, path) {
        if (!file.contains('/domain/')) return false;
        return path.contains('/presentation/') ||
            path.contains('/data/') ||
            path.startsWith('lib/ui/') ||
            path.startsWith('lib/widgets/') ||
            path.startsWith('lib/core/network/') ||
            path.startsWith('lib/core/router/') ||
            path.startsWith('package:flutter');
      },
      reason:
          'Domain must be pure and independent from UI, data, and infra.',
    );
  });

  test('data layer does not depend on presentation or ui', () {
    _expectNoForbiddenImports(
      roots: const ['lib/features'],
      isForbidden: (file, path) {
        if (!file.contains('/data/')) return false;
        return path.contains('/presentation/') ||
            path.startsWith('lib/ui/') ||
            path.startsWith('lib/widgets/');
      },
      reason: 'Data layer should not import presentation or UI components.',
    );
  });

  test('ui layer stays inside ui', () {
    _expectNoForbiddenImports(
      roots: const ['lib/ui'],
      isForbidden: (_, path) => !path.startsWith('lib/ui/'),
      reason: 'lib/ui can only depend on lib/ui local files.',
    );
  });

  test('core and managers do not import feature presentation/data', () {
    _expectNoForbiddenImports(
      roots: const ['lib/core', 'lib/managers', 'lib/bootstrap.dart'],
      isForbidden: (_, path) =>
          path.contains('/features/') &&
          (path.contains('/presentation/') || path.contains('/data/')),
      reason:
          'Core/managers/bootstrap must depend on abstractions or composition '
          'roots, not feature implementations.',
    );
  });
}
