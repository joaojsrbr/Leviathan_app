// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum TypeEvent {
  RELEASE('latest', 'Recém Adicionado', MdiIcons.history),
  TRENDING('trending', 'Em Alta', MdiIcons.trendingUp),
  NEW_BOOK('newmanga', 'Manga Novo', MdiIcons.newBox),
  RATING('rating', 'Bem Avaliado', MdiIcons.star),
  MOST_VIEWED('views', 'Mais Lidos', MdiIcons.magnifyPlusOutline);

  final String order;
  final String title;
  final IconData iconData;

  const TypeEvent(this.order, this.title, this.iconData);
}
