import 'package:flutter/widgets.dart';
import 'package:lextari/ui/icons/app_glyphs.dart';
import 'package:prism_ui/prism_ui.dart';

/// Illustrations for Lextari's empty and error pages.
enum NullStatusIllustration implements Illustration {
  data,
  devices,
  logs,
  proxies,
  profile,
  scripts,
  rules,
  connections,
  requests,
  dns,
  ntp,
  sniffer,
  tun,
  wifi,
  apps,
  icons,
  fonts,
  permission,
  camera,
  error;

  @override
  Glyph get glyph => switch (this) {
    data => AppGlyphs.barChart,
    devices => AppGlyphs.device,
    logs => AppGlyphs.description,
    proxies => AppGlyphs.device,
    profile => AppGlyphs.home,
    scripts => AppGlyphs.description,
    rules => AppGlyphs.settings,
    connections => AppGlyphs.waves,
    requests => AppGlyphs.cloud,
    dns => AppGlyphs.language,
    ntp => AppGlyphs.autorenew,
    sniffer => AppGlyphs.eye,
    tun => AppGlyphs.privacyTip,
    wifi => AppGlyphs.cloud,
    apps => AppGlyphs.device,
    icons => AppGlyphs.tune,
    fonts => AppGlyphs.description,
    permission => AppGlyphs.privacyTip,
    camera => AppGlyphs.eye,
    error => AppGlyphs.error,
  };

  @override
  bool get isError => this == error;
}

/// A centered empty state with an illustration, label and optional action.
class EmptyState extends StatelessWidget {
  /// Creates an [EmptyState].
  const EmptyState({
    super.key,
    this.illustration = NullStatusIllustration.data,
    this.label,
    this.description,
    this.action,
  });

  /// Illustration shown above the label.
  final Illustration illustration;

  /// Short title.
  final String? label;

  /// Longer explanation under the title.
  final String? description;

  /// Optional call to action.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return NullStatus(
      illustration: illustration,
      label: label,
      description: description,
      action: action,
    );
  }
}

/// A centered error state that uses the error illustration.
class ErrorState extends StatelessWidget {
  /// Creates an [ErrorState].
  const ErrorState({
    super.key,
    this.label,
    this.description,
    this.action,
  });

  /// Short title.
  final String? label;

  /// Longer explanation under the title.
  final String? description;

  /// Optional retry action.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return NullStatus(
      illustration: NullStatusIllustration.error,
      label: label,
      description: description,
      action: action,
    );
  }
}
