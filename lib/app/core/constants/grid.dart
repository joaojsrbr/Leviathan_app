// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum ModeView {
  GRID_3X3('GridView Pequeno'),
  GRID_2X2('GridView Grande'),
  PAGEVIEW('PageView');

  final String label;

  const ModeView(this.label);
}

class Grid {
  Grid._();
  static const GRIDDELEGATE = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    crossAxisCount: 2,
    childAspectRatio: 1,
  );

  // static const BOOKGRIDDELEGATE = SliverGridDelegateWithFixedCrossAxisCount(
  //   crossAxisCount: 2,
  //   crossAxisSpacing: 10,
  //   mainAxisSpacing: 10,
  //   mainAxisExtent: 180,
  // );

  static const FAVORITEGRIDDELEGATE = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 160,
    childAspectRatio: 1,
    crossAxisSpacing: 8,
    mainAxisSpacing: 10,
    mainAxisExtent: 155,
  );

  static const BOOKGRIDDELEGATE = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    mainAxisExtent: 180,
  );
  // static const BOOKGRIDDELEGATE = SliverGridDelegateWithMaxCrossAxisExtent(
  //   maxCrossAxisExtent: 182,
  //   crossAxisSpacing: 8,
  //   mainAxisSpacing: 8,
  //   childAspectRatio: 1,
  //   mainAxisExtent: 160,
  // );
}
