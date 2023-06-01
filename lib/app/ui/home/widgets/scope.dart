import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScope extends InheritedWidget {
  const HomeScope({
    super.key,
    required super.child,
    required this.persistentFooterButtons,
    required this.activeOverFlowWidget,
    required this.activeOverflow,
  });
  final List<Widget> persistentFooterButtons;
  final bool activeOverflow;

  static HomeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeScope>();
  }

  final void Function(bool active, [List<Widget>? persistentFooterButtons]) activeOverFlowWidget;

  static HomeScope of(BuildContext context) {
    final HomeScope? result = maybeOf(context);
    assert(result != null, 'No HomeScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(HomeScope oldWidget) =>
      activeOverflow != oldWidget.activeOverflow || !listEquals(persistentFooterButtons, oldWidget.persistentFooterButtons);
}
