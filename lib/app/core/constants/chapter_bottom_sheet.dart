// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum ChapterBottomSheetOptions {
  SHARE('Compartilhar', MdiIcons.share),
  WEBVIEW('Abra em webview', MdiIcons.web),
  ANTERIORESLIDO('Marcar capítulos anteriores como lidos', MdiIcons.eyePlus),
  ANTERIORESNLIDO('Marcar capítulos anteriores como não lidos', MdiIcons.eyeRemove),
  INTERVALOLIDO('Marcar um intervalo de capítulos como lido', MdiIcons.eyeSettings),
  INTERVALONLIDO('Marcar um intervalo de capítulos como não lido', MdiIcons.eyeSettingsOutline);

  final IconData icon;
  final String label;

  const ChapterBottomSheetOptions(this.label, this.icon);
}
