// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum HomeSelect {
  Home(MdiIcons.homeOutline, MdiIcons.home, 'Home'),
  BIBLIOTECA(MdiIcons.bookOutline, MdiIcons.book, 'Biblioteca');

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const HomeSelect(this.icon, this.selectedIcon, this.label);
}
