import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get mediaQuerySize => MediaQuery.sizeOf(this);

  Orientation get orientation => MediaQuery.orientationOf(this);

  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  EdgeInsets get padding => MediaQuery.paddingOf(this);

  // Theme
  TextTheme get textTheme => themeData.textTheme;

  ThemeData get themeData => Theme.of(this);

  ColorScheme get colorScheme => themeData.colorScheme;

  // LibraryRepository libraryRepository([bool listen = true]) => Provider.of<LibraryRepository>(this, listen: listen);
}
