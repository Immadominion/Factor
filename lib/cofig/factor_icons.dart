import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Centralized icon definitions using Phosphor icons.
///
/// All icons use consistent sizing via ScreenUtil for responsiveness.
/// Default size is 24.r (responsive) which equals ~26px at design scale.
class FactorIcons {
  FactorIcons._();

  /// Default icon size (moderate, ~26px equivalent)
  static double get defaultSize => 24.r;

  /// Small icon size (~18px equivalent)
  static double get smallSize => 16.r;

  /// Medium icon size (~28px equivalent)
  static double get mediumSize => 26.r;

  /// Large icon size (~34px equivalent)
  static double get largeSize => 32.r;

  /// Extra large icon size (~50px equivalent)
  static double get xlSize => 48.r;

  // Navigation & Actions
  static const gear = PhosphorIconsBold.gear;
  static const arrowLeft = PhosphorIconsBold.arrowLeft;
  static const arrowRight = PhosphorIconsBold.arrowRight;
  static const arrowUp = PhosphorIconsBold.arrowUp;
  static const arrowDown = PhosphorIconsBold.arrowDown;
  static const arrowUpRight = PhosphorIconsBold.arrowUpRight;
  static const close = PhosphorIconsBold.x;
  static const closeCircle = PhosphorIconsBold.xCircle;
  static const search = PhosphorIconsBold.magnifyingGlass;
  static const check = PhosphorIconsBold.check;
  static const checkCircle = PhosphorIconsBold.checkCircle;
  static const chevronDown = PhosphorIconsBold.caretDown;
  static const chevronUp = PhosphorIconsBold.caretUp;

  // Settings & Preferences
  static const palette = PhosphorIconsBold.palette;
  static const vibrate = PhosphorIconsBold.vibrate;
  static const waveform = PhosphorIconsBold.waveform;
  static const sun = PhosphorIconsBold.sun;
  static const moon = PhosphorIconsBold.moon;
  static const deviceMobile = PhosphorIconsBold.deviceMobile;

  // Communication & Social
  static const envelope = PhosphorIconsBold.envelope;
  static const users = PhosphorIconsBold.users;
  static const storefront = PhosphorIconsBold.storefront;

  // Legal & Documents
  static const scroll = PhosphorIconsBold.scroll;
  static const shieldCheck = PhosphorIconsBold.shieldCheck;

  // Status
  static const cloudOff = PhosphorIconsBold.cloudSlash;
  static const error = PhosphorIconsBold.warningCircle;

  // Additional useful icons
  static const copy = PhosphorIconsBold.copy;
  static const share = PhosphorIconsBold.shareFat;
  static const info = PhosphorIconsBold.info;
  static const warning = PhosphorIconsBold.warning;
  static const refresh = PhosphorIconsBold.arrowClockwise;
  static const swap = PhosphorIconsBold.arrowsLeftRight;
  static const coins = PhosphorIconsBold.coins;
  static const currencyDollar = PhosphorIconsBold.currencyDollar;
  static const chartLine = PhosphorIconsBold.chartLine;
  static const globe = PhosphorIconsBold.globe;
  static const link = PhosphorIconsBold.link;
}

/// Helper widget to display a Phosphor icon with consistent styling and sizing.
///
/// Uses ScreenUtil for responsive sizing. Default size is [FactorIcons.defaultSize].
class FactorIcon extends StatelessWidget {
  const FactorIcon(this.icon, {super.key, this.size, this.color});

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size ?? FactorIcons.defaultSize,
      color: color ?? Theme.of(context).iconTheme.color,
    );
  }
}
