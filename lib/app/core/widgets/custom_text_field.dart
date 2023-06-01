import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.onEditingComplete,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.label,
    this.focusNode,
    this.autovalidateMode,
    this.onChanged,
    this.onButtonPressed,
    this.copyDecoration,
    this.permaButton,
    this.autofocus = false,
  });

  final VoidCallback? onEditingComplete;
  final InputDecoration Function(InputDecoration decoration)? copyDecoration;
  final VoidCallback? onButtonPressed;
  final TextEditingController controller;
  final AutovalidateMode? autovalidateMode;
  final Widget? label;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool? permaButton;
  final bool autofocus;

  void _unfocusKeyBoard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final decoration = InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      filled: true,
      label: label,
      suffixIconColor: colorScheme.primary,
      suffixIconConstraints: const BoxConstraints(maxWidth: 35),
      suffixIcon: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => permaButton == true
            ? child!
            : controller.text.trim().isEmpty
                ? const SizedBox.shrink()
                : child!,
        child: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            onPressed: () {
              if (permaButton == true) {
                if (controller.text.isNotEmpty) {
                  controller.clear();
                } else {
                  _unfocusKeyBoard(context);
                  onButtonPressed?.call();
                }
              } else {
                controller.clear();
                _unfocusKeyBoard(context);
                onButtonPressed?.call();
              }
            },
            padding: EdgeInsets.zero,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
            iconSize: 20,
            icon: const Icon(MdiIcons.close),
          ),
        ),
      ),
      contentPadding: const EdgeInsets.only(left: 15.0, right: 15.0),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusColor: colorScheme.background.withOpacity(0.5),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
      ),
    );

    return TextFormField(
      onEditingComplete: () {
        _unfocusKeyBoard(context);
        onEditingComplete?.call();
      },
      onChanged: onChanged,
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      autofocus: autofocus,
      keyboardType: keyboardType,
      autovalidateMode: autovalidateMode,
      decoration: copyDecoration?.call(decoration) ?? decoration,
    );
  }
}
