import 'package:flutter/material.dart';

abstract class AppColors {
  static const violet = Color(0xFF7C3AED);
  static const violetLight = Color(0xFFA78BFA);
  static const blue = Color(0xFF2563EB);
  static const cyan = Color(0xFF06B6D4);
  static const amber = Color(0xFFF59E0B);
  static const pink = Color(0xFFEC4899);
  static const green = Color(0xFF4ADE80);
  static const red = Color(0xFFF87171);
  static const bg = Color(0xFF070714);
  static const bgCard = Color(0xFF0D0D26);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB8F0F0FF);
  static const textTertiary = Color(0x6BC8C8F0);
  static const glassBg = Color(0x14FFFFFF);
  static const glassBorder = Color(0x2EFFFFFF);
  static const glassBgSm = Color(0x0FFFFFFF);
  static const glassBorderSm = Color(0x1EFFFFFF);
  static const priorityLow = Color(0xFF4ADE80);
  static const priorityNormal = Color(0xFF60A5FA);
  static const priorityHigh = Color(0xFFF59E0B);
  static const priorityCritical = Color(0xFFF87171);

  static Color forPriority(int level) {
    if (level == 0) return priorityLow;
    if (level == 2) return priorityHigh;
    if (level == 3) return priorityCritical;
    return priorityNormal;
  }

  static Color bgForPriority(int level) =>
      forPriority(level).withOpacity(0.12);
}
