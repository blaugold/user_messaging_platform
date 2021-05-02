import 'package:flutter/material.dart';

ThemeData lightTheme() =>
    _applyCustomTheme(ThemeData.from(colorScheme: ColorScheme.light()));

ThemeData darkTheme() =>
    _applyCustomTheme(ThemeData.from(colorScheme: ColorScheme.light()));

ThemeData _applyCustomTheme(ThemeData theme) {
  return theme;
}
