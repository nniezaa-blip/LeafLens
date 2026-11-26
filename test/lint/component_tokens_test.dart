import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _componentFiles = <String>[
  'lib/features/dashboard/presentation/dashboard_style.dart',
  'lib/features/dashboard/presentation/widgets/action_switch.dart',
  'lib/features/dashboard/presentation/widgets/care_controls_card.dart',
  'lib/features/dashboard/presentation/widgets/dashboard_card.dart',
  'lib/features/dashboard/presentation/widgets/dashboard_skeleton.dart',
  'lib/features/dashboard/presentation/widgets/environment_card.dart',
  'lib/features/dashboard/presentation/widgets/health_score_card.dart',
  'lib/features/dashboard/presentation/widgets/water_system_card.dart',
  'lib/ui/primitives/botanical_background.dart',
];

final _checks = <(String, RegExp)>[
  ('raw colour', RegExp(r'Color\(0x[0-9A-Fa-f]+\)')),
  ('raw radius', RegExp(r'BorderRadius\.circular\(\s*\d+(?:\.\d+)?\s*\)')),
  (
    'raw edge insets',
    RegExp(r'EdgeInsets\.(?:all|symmetric|fromLTRB|only)\([^)]*\b\d+(?:\.\d+)?\b'),
  ),
  (
    'raw sized box',
    RegExp(r'SizedBox\(\s*(?:width|height):\s*\d+(?:\.\d+)?'),
  ),
  ('raw shape radius', RegExp(r'AppShape\.all\(\s*\d+(?:\.\d+)?')),
  ('raw alpha', RegExp(r'withValues\(alpha:\s*0\.')),
  ('raw duration', RegExp(r'Duration\(milliseconds:\s*\d+')),
];

void main() {
  test('dashboard components use design tokens instead of magic values', () {
    final offenders = <String>[];
    for (final path in _componentFiles) {
      final file = File(path);
      if (!file.existsSync()) {
        offenders.add('$path (missing)');
        continue;
      }
      final source = file.readAsStringSync();
      for (final (label, pattern) in _checks) {
        for (final match in pattern.allMatches(source)) {
          offenders.add('$path: $label: ${match.group(0)}');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Component values must come from AppSpacing, AppRadii, AppSizes, '
          'AppOpacity, AppDurations or the colour scheme.\n'
          '${offenders.join('\n')}',
    );
  });
}
