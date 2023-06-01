import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EmoticonsView extends StatefulWidget {
  const EmoticonsView({
    super.key,
    required this.text,
    this.style,
    this.errorFacesStyle,
    this.button,
  });
  final TextStyle? style;
  final TextStyle? errorFacesStyle;
  final String text;
  final Widget? button;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(StringProperty('error_message', text, showName: false));
    super.debugFillProperties(properties);
  }

  @override
  State<EmoticonsView> createState() => _EmoticonsViewState();
}

class _EmoticonsViewState extends State<EmoticonsView> {
  final List<String> _errorFaces = const [
    '(･o･;)',
    'Σ(ಠ_ಠ)',
    'ಥ_ಥ',
    '(˘･_･˘)',
    '(；￣Д￣)',
    '(･Д･。',
  ];

  final Random _random = Random();
  late final String data;

  @override
  void initState() {
    data = _errorFaces[_random.nextInt(6)];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListTile(
          title: Text(
            data,
            textAlign: TextAlign.center,
            style: widget.errorFacesStyle ?? Theme.of(context).textTheme.headlineLarge,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: widget.style ?? Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        if (widget.button != null) widget.button!
      ],
    );
  }
}
