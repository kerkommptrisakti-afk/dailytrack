import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class GlassStyle {
  static const double blurMd = 28.0;
  static const double blurSm = 16.0;
  static const double blurXs = 12.0;

  static const double radiusCard = 24.0;
  static const double radiusCardSm = 16.0;
  static const double radiusItem = 18.0;
  static const double radiusPill = 100.0;
  static const double radiusIcon = 14.0;

  static const BorderRadius borderCard =
      BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius borderCardSm =
      BorderRadius.all(Radius.circular(radiusCardSm));
  static const BorderRadius borderItem =
      BorderRadius.all(Radius.circular(radiusItem));
  static const BorderRadius borderPill =
      BorderRadius.all(Radius.circular(radiusPill));

  static final List<BoxShadow> glowViolet = [
    BoxShadow(
      color: AppColors.violet.withOpacity(0.25),
      blurRadius: 40,
    ),
    BoxShadow(
      color: AppColors.blue.withOpacity(0.15),
      blurRadius: 80,
    ),
  ];

  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
  ];

  static const innerShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1EFFFFFF), Colors.transparent],
    stops: [0.0, 0.5],
  );

  static BoxDecoration card({List<BoxShadow>? glow}) => BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: borderCard,
        border: Border.all(color: AppColors.glassBorder, width: 1.0),
        boxShadow: glow ?? cardShadow,
      );

  static BoxDecoration cardSm({List<BoxShadow>? glow}) => BoxDecoration(
        color: AppColors.glassBgSm,
        borderRadius: borderCardSm,
        border: Border.all(color: AppColors.glassBorderSm, width: 1.0),
        boxShadow: glow,
      );
}
