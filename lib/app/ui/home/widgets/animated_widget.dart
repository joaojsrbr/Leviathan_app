import 'package:flutter/material.dart';

class CustomAnimatedWidget extends StatelessWidget {
  const CustomAnimatedWidget({
    super.key,
    required this.active,
    required this.child,
    this.replaceWidget = const SizedBox.shrink(),
  });
  final bool active;
  final Widget replaceWidget;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: active ? child : replaceWidget,
    );
  }
}
