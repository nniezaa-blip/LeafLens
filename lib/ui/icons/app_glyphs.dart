import 'dart:math' as math;

import 'package:prism_ui/icons/glyph.dart';
import 'package:prism_ui/icons/glyphs.dart';

abstract final class AppGlyphs {
  static const Glyph arrowBack = Glyphs.arrowBack;
  static const Glyph chevronForward = Glyphs.chevronForward;
  static const Glyph chevronRight = Glyphs.chevronForward;
  static const Glyph close = Glyphs.close;
  static const Glyph check = Glyphs.check;
  static const Glyph eye = Glyphs.eye;
  static const Glyph eyeOff = Glyphs.eyeOff;
  static const Glyph visibility = Glyphs.eye;
  static const Glyph visibilityOff = Glyphs.eyeOff;
  static const info = Glyph([
    GlyphCircle(12, 12, 8.8),
    GlyphCircle(12, 7.5, 1.4, role: GlyphRole.detail, solid: true),
    GlyphPolyline([
      GlyphVertex(12, 11.8),
      GlyphVertex(12, 16.7),
    ], role: GlyphRole.detail),
  ]);
  static const warning = Glyph([
    GlyphPolyline([
      GlyphVertex(12, 1.6, 3),
      GlyphVertex(21.9, 20.3, 2.5),
      GlyphVertex(2.1, 20.3, 2.5),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(12, 9),
      GlyphVertex(12, 12.1),
    ], role: GlyphRole.detail),
    GlyphCircle(12, 16.2, 1.4, role: GlyphRole.detail, solid: true),
  ]);
  static const error = Glyph([
    GlyphCircle(12, 12, 8.8),
    GlyphPolyline([
      GlyphVertex(12, 7.3),
      GlyphVertex(12, 12.2),
    ], role: GlyphRole.detail),
    GlyphCircle(12, 16.5, 1.4, role: GlyphRole.detail, solid: true),
  ]);
  static const checkCircle = Glyph([
    GlyphCircle(12, 12, 8.8),
    GlyphPolyline([
      GlyphVertex(7.59, 12.3),
      GlyphVertex(10.49, 15.2),
      GlyphVertex(16.41, 8.79),
    ], role: GlyphRole.detail),
  ]);
  static const settings = Glyph([
    GlyphPolyline([
      GlyphVertex(9.87, 5.44, 0.6),
      GlyphVertex(10.09, 3, 0.9),
      GlyphVertex(13.91, 3, 0.9),
      GlyphVertex(14.13, 5.44, 0.6),
      GlyphVertex(16.62, 6.87, 0.6),
      GlyphVertex(18.84, 5.84, 0.9),
      GlyphVertex(20.75, 9.16, 0.9),
      GlyphVertex(18.75, 10.57, 0.6),
      GlyphVertex(18.75, 13.43, 0.6),
      GlyphVertex(20.75, 14.84, 0.9),
      GlyphVertex(18.84, 18.16, 0.9),
      GlyphVertex(16.62, 17.13, 0.6),
      GlyphVertex(14.13, 18.56, 0.6),
      GlyphVertex(13.91, 21, 0.9),
      GlyphVertex(10.09, 21, 0.9),
      GlyphVertex(9.87, 18.56, 0.6),
      GlyphVertex(7.38, 17.13, 0.6),
      GlyphVertex(5.16, 18.16, 0.9),
      GlyphVertex(3.25, 14.84, 0.9),
      GlyphVertex(5.25, 13.43, 0.6),
      GlyphVertex(5.25, 10.57, 0.6),
      GlyphVertex(3.25, 9.16, 0.9),
      GlyphVertex(5.16, 5.84, 0.9),
      GlyphVertex(7.38, 6.87, 0.6),
    ], closed: true),
    GlyphCircle(12, 12, 3, role: GlyphRole.detail),
  ]);
  static const language = Glyph([
    GlyphPolyline([
      GlyphVertex(3.2, 3.9, 3),
      GlyphVertex(20.8, 3.9, 3),
      GlyphVertex(20.8, 17.5, 3),
      GlyphVertex(10, 17.5, 0.8),
      GlyphVertex(6.2, 21, 0.6),
      GlyphVertex(6.2, 17.5, 0.6),
      GlyphVertex(3.2, 17.5, 3),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(8.6, 14.1),
      GlyphVertex(12, 7.3, 0.4),
      GlyphVertex(15.4, 14.1),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(9.85, 11.6),
      GlyphVertex(14.15, 11.6),
    ], role: GlyphRole.detail),
  ]);
  static const tune = Glyph([
    GlyphPolyline([
      GlyphVertex(3.2, 5.5),
      GlyphVertex(10.4, 5.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(18.6, 5.5),
      GlyphVertex(20.8, 5.5),
    ], role: GlyphRole.line),
    GlyphCircle(14.5, 5.5, 2.5),
    GlyphPolyline([
      GlyphVertex(3.2, 12),
      GlyphVertex(4.4, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12.6, 12),
      GlyphVertex(20.8, 12),
    ], role: GlyphRole.line),
    GlyphCircle(8.5, 12, 2.5),
    GlyphPolyline([
      GlyphVertex(3.2, 18.5),
      GlyphVertex(11.4, 18.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(19.6, 18.5),
      GlyphVertex(20.8, 18.5),
    ], role: GlyphRole.line),
    GlyphCircle(15.5, 18.5, 2.5),
  ]);
  static const autorenew = Glyph([
    GlyphArc(
      12,
      12,
      7.78,
      math.pi * 1.144,
      math.pi * 0.889,
      role: GlyphRole.line,
    ),
    GlyphPolyline([
      GlyphVertex(5, 5),
      GlyphVertex(5, 8.6, 0.4),
      GlyphVertex(8.6, 8.6),
    ], role: GlyphRole.line),
    GlyphArc(
      12,
      12,
      7.78,
      math.pi * 0.144,
      math.pi * 0.889,
      role: GlyphRole.line,
    ),
    GlyphPolyline([
      GlyphVertex(19, 19),
      GlyphVertex(19, 15.4, 0.4),
      GlyphVertex(15.4, 15.4),
    ], role: GlyphRole.line),
  ]);

  // Lextari-specific glyphs
  static const home = Glyph([
    GlyphPolyline([
      GlyphVertex(3.5, 10.2, 1.5),
      GlyphVertex(12, 3.2, 1.2),
      GlyphVertex(20.5, 10.2, 1.5),
      GlyphVertex(20.5, 20, 2),
      GlyphVertex(14.2, 20, 0.8),
      GlyphVertex(14.2, 14.2, 0.8),
      GlyphVertex(9.8, 14.2, 0.8),
      GlyphVertex(9.8, 20, 0.8),
      GlyphVertex(3.5, 20, 2),
    ], closed: true),
  ]);

  static const barChart = Glyph([
    GlyphBox(3.8, 10.5, 7.2, 20.2, 1.2),
    GlyphBox(10.3, 4.2, 13.7, 20.2, 1.2),
    GlyphBox(16.8, 7.8, 20.2, 20.2, 1.2),
  ]);

  static const notificationsPaused = Glyph([
    GlyphPath(
      'M15 17h5l-1.4-1.4A2 2 0 0 1 18 14.2V11a6 6 0 1 0-12 0v3.2a2 2 0 0 1-.6 1.4L4 17h5',
      role: GlyphRole.line,
    ),
    GlyphPath('M9 17v1a3 3 0 0 0 6 0v-1', role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(9.4, 9.2),
      GlyphVertex(9.4, 13.2),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(14.6, 9.2),
      GlyphVertex(14.6, 13.2),
    ], role: GlyphRole.line),
  ]);

  static const darkMode = Glyph([
    GlyphPath('M20.5 14.2A8.8 8.8 0 1 1 9.8 3.5a6.8 6.8 0 0 0 10.7 10.7Z'),
  ]);

  static const description = Glyph([
    GlyphPolyline([
      GlyphVertex(5, 3, 2.5),
      GlyphVertex(13.5, 3, 1),
      GlyphVertex(19, 8.5, 1),
      GlyphVertex(19, 21, 2.5),
      GlyphVertex(5, 21, 2.5),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(13.5, 3.2),
      GlyphVertex(13.5, 8.5, 1.5),
      GlyphVertex(18.8, 8.5),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(8.2, 12.8),
      GlyphVertex(15.8, 12.8),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(8.2, 16.4),
      GlyphVertex(14.2, 16.4),
    ], role: GlyphRole.detail),
  ]);

  static const privacyTip = Glyph([
    GlyphPolyline([
      GlyphVertex(12, 2.9, 1.5),
      GlyphVertex(19.6, 5.5, 2),
      GlyphVertex(19.6, 12.5, 5),
      GlyphVertex(12, 21.1, 2.5),
      GlyphVertex(4.4, 12.5, 5),
      GlyphVertex(4.4, 5.5, 2),
    ], closed: true),
    GlyphPolyline([
      GlyphVertex(12, 8.2),
      GlyphVertex(12, 12.2),
    ], role: GlyphRole.detail),
    GlyphCircle(12, 15.6, 1.2, role: GlyphRole.detail, solid: true),
  ]);

  static const logout = Glyph([
    GlyphPolyline([
      GlyphVertex(9.5, 4),
      GlyphVertex(5, 4, 2),
      GlyphVertex(5, 20, 2),
      GlyphVertex(9.5, 20),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12.5, 12),
      GlyphVertex(20.5, 12),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(17.2, 8.7),
      GlyphVertex(20.5, 12, 0.4),
      GlyphVertex(17.2, 15.3),
    ], role: GlyphRole.line),
  ]);

  static const waterDrop = Glyph([
    GlyphPath(
      'M12 2.8C12 2.8 5.8 9.6 5.8 14.2A6.2 6.2 0 0 0 18.2 14.2C18.2 9.6 12 2.8 12 2.8Z',
    ),
  ]);

  static const thermostat = Glyph([
    GlyphPath('M14 14.6V5a2 2 0 1 0-4 0v9.6a4.2 4.2 0 1 0 4 0Z'),
    GlyphPolyline([
      GlyphVertex(14, 7.2),
      GlyphVertex(16.4, 7.2),
    ], role: GlyphRole.detail),
    GlyphPolyline([
      GlyphVertex(14, 10),
      GlyphVertex(16.4, 10),
    ], role: GlyphRole.detail),
  ]);

  static const grass = Glyph([
    GlyphPath('M5 20c0-4.8 1.8-7.8 4-10', role: GlyphRole.line),
    GlyphPath('M12 20c0-7 2.2-11 5.2-14', role: GlyphRole.line),
    GlyphPath('M19 20c0-3.8-1-6-3-8.2', role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(3.5, 20),
      GlyphVertex(20.5, 20),
    ], role: GlyphRole.line),
  ]);

  static const waves = Glyph([
    GlyphPath(
      'M3 7.2c1.8-1.8 3.6-1.8 5.4 0s3.6 1.8 5.4 0 3.6-1.8 5.4 0',
      role: GlyphRole.line,
    ),
    GlyphPath(
      'M3 12c1.8-1.8 3.6-1.8 5.4 0s3.6 1.8 5.4 0 3.6-1.8 5.4 0',
      role: GlyphRole.line,
    ),
    GlyphPath(
      'M3 16.8c1.8-1.8 3.6-1.8 5.4 0s3.6 1.8 5.4 0 3.6-1.8 5.4 0',
      role: GlyphRole.line,
    ),
  ]);

  static const sensorsOff = Glyph([
    GlyphCircle(12, 12, 2.2),
    GlyphPath('M7.2 7.2A6.8 6.8 0 0 0 5.2 12', role: GlyphRole.line),
    GlyphPath('M16.8 7.2A6.8 6.8 0 0 1 18.8 12', role: GlyphRole.line),
    GlyphPath('M4.2 4.2A11 11 0 0 0 2 12', role: GlyphRole.line),
    GlyphPath('M19.8 4.2A11 11 0 0 1 22 12', role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(3.5, 3.5),
      GlyphVertex(20.5, 20.5),
    ], role: GlyphRole.line),
  ]);

  static const cloud = Glyph([
    GlyphPath(
      'M7 19.4A4.2 4.2 0 0 1 5.06 11.47A6 6 0 1 1 16.95 9.83A4.8 4.8 0 0 1 16.4 19.4Z',
    ),
  ]);

  static const cloudOff = Glyph([
    GlyphPath(
      'M7 19.4A4.2 4.2 0 0 1 5.06 11.47A6 6 0 0 1 9.2 5.9',
      role: GlyphRole.line,
    ),
    GlyphPath(
      'M12.8 4.4A6 6 0 0 1 16.95 9.83A4.8 4.8 0 0 1 16.4 19.4H9.4',
      role: GlyphRole.line,
    ),
    GlyphPolyline([
      GlyphVertex(3.5, 3.5),
      GlyphVertex(20.5, 20.5),
    ], role: GlyphRole.line),
  ]);

  static const doubleArrow = Glyph([
    GlyphPolyline([
      GlyphVertex(5.2, 7),
      GlyphVertex(10.2, 12, 0.4),
      GlyphVertex(5.2, 17),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12.8, 7),
      GlyphVertex(17.8, 12, 0.4),
      GlyphVertex(12.8, 17),
    ], role: GlyphRole.line),
  ]);

  static const device = Glyph([
    GlyphBox(4.2, 5.2, 19.8, 15.2, 1.6),
    GlyphPolyline([
      GlyphVertex(9.2, 18.8),
      GlyphVertex(14.8, 18.8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(12, 15.2),
      GlyphVertex(12, 18.8),
    ], role: GlyphRole.line),
    GlyphCircle(12, 10.2, 1.2, role: GlyphRole.detail, solid: true),
  ]);
}
