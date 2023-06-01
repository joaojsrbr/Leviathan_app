import 'package:flutter/material.dart';

part 'color_schemes.g.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  applyElevationOverlayColor: true,
  brightness: Brightness.light,
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    ),
  ),
  scrollbarTheme: ScrollbarThemeData(thumbColor: MaterialStatePropertyAll(_lightColorScheme.primary)),
  colorScheme: _lightColorScheme,
);

final darkTheme = ThemeData(
  useMaterial3: true,
  applyElevationOverlayColor: true,
  scrollbarTheme: ScrollbarThemeData(thumbColor: MaterialStatePropertyAll(_darkColorScheme.primary)),
  brightness: Brightness.dark,
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    ),
  ),
  colorScheme: _darkColorScheme,
);
