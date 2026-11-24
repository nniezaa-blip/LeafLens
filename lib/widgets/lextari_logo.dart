import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Lextari brand logo — used on splash, login, and app bar.
class LextariLogo extends StatelessWidget {
  // final double width;
  // final double height;

  /// Creates a [LextariLogo] widget.
  const LextariLogo({
    super.key,
    // this.width = 156,
    // this.height = 202,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/splash_illustration.svg',
      // width: width,
      // height: height,
    );
  }
}
