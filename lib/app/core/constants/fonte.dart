// ignore_for_file: constant_identifier_names

import 'package:leviathan_app/app/core/constants/app.dart';

enum Fonte {
  NEOX_SCANS('Neox Scans', App.NEOXURL),
  MANGA_BTT('Manga BTT', App.MANGABTTURL);

  final String baseURL;
  final String label;

  const Fonte(this.label, this.baseURL);
}
