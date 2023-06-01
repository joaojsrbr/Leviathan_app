import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/constants/fonte.dart';
import 'package:leviathan_app/app/core/constants/grid.dart';
import 'package:leviathan_app/app/core/constants/type_event.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/core/repositories/load_book_repository.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:leviathan_app/app/core/widgets/menu_widget.dart';
import 'package:provider/provider.dart';

class Buttons extends StatefulWidget implements PreferredSizeWidget {
  const Buttons({
    super.key,
    this.isBiblioteca = false,
  });

  final bool isBiblioteca;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight - 8);

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  late final List<bool> _typeEventSelect;
  late final List<bool> _modeView;

  late final HiveController _hiveController;
  late final LoadBookRepository _allRepository;

  @override
  void initState() {
    _modeView = List.generate(ModeView.values.getRange(0, 2).length, (index) => false);
    _typeEventSelect = List.generate(TypeEvent.values.length, (index) => false);

    _hiveController = context.read();
    _allRepository = context.read();
    _typeEventSelect[_hiveController.type.index] = true;
    _modeView[_hiveController.modeView.index] = true;

    super.initState();
  }

  void _onPressedTypeEvent(int index) async {
    final type = TypeEvent.values.elementAt(index);
    if (type == _hiveController.type) return;
    await _hiveController.setTypeEvent(type).whenComplete(() => _setTypeEventToggleButton(type));
    final repository = _allRepository.repository;
    if (type != repository.type) repository.setType = type;
    await repository.refresh(true);
  }

  // void _onModeView(int index) async {
  //   final homeSelect = ModeView.values.elementAt(index);
  //   if (homeSelect == _hiveController.modeView) return;
  //   await _hiveController.setModeView(homeSelect).whenComplete(() => _setodeViewToggleButton(homeSelect));
  // }

  // void _setodeViewToggleButton(ModeView modeView) {
  //   setState(() {
  //     _modeView[modeView.index] = true;

  //     for (int i = 0; i < _modeView.length; i++) {
  //       if (i == modeView.index) continue;
  //       _modeView[i] = false;
  //     }
  //   });
  // }

  void _setTypeEventToggleButton(TypeEvent type) {
    setState(() {
      _typeEventSelect[type.index] = true;

      for (int i = 0; i < _typeEventSelect.length; i++) {
        if (i == type.index) continue;
        _typeEventSelect[i] = false;
      }

      // _typeEventSelect.update(type, (value) => true);
      // for (final item in _typeEventSelect.entries) {
      //   if (item.key == type) continue;
      //   _typeEventSelect.update(item.key, (value) => false);
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = context.themeData;
    final orientation = context.orientation;
    final size = context.mediaQuerySize;

    final borderRadius = BorderRadius.circular(8);
    final padding = EdgeInsets.only(left: size.width * .04);
    final constraints = BoxConstraints(
      maxWidth: orientation == Orientation.portrait ? size.width * .32 : size.height * .32,
      minWidth: orientation == Orientation.portrait ? size.width * .2 : size.height * .045,
      minHeight: orientation == Orientation.portrait ? size.height * .045 : size.width * .050,
      maxHeight: orientation == Orientation.portrait ? size.height * .045 : size.width * .050,
    );
    final width = orientation == Orientation.portrait ? size.width * 0.48 / 5 : size.height * 0.48 / 5;
    final isBiblioteca = widget.isBiblioteca;
    final hiveController = context.watch<HiveController>();
    // final isHome = hiveController.homeSelect == HomeSelect.Home;
    final loadBookRepository = context.watch<LoadBookRepository>();
    final disableButton = loadBookRepository.disableButton;
    final error = loadBookRepository.error;

    return SizedBox(
      width: size.width,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isBiblioteca)
                Padding(
                  padding: EdgeInsets.only(right: 8, bottom: disableButton ? 6 : 0),
                  child: MenuWidget(
                    disableButton: error,
                    onChange: (selected) async {
                      if (selected == hiveController.fonte) return;
                      await hiveController.setFonte(selected);
                      _allRepository.switchRepository();
                      _allRepository.repository.refresh(true);
                    },
                    items: Fonte.values,
                    padding: EdgeInsets.zero,
                    data: hiveController.fonte,
                    borderRadius: borderRadius,
                    constraints: constraints,
                    label: (data) => data.label,
                    menuBorderRadius: BorderRadius.circular(6),
                  ),
                ),

              // ToggleButtons(
              //   onPressed: _onHomeSelect,
              //   borderRadius: borderRadius,
              //   isSelected: _homeSelect,
              //   constraints: BoxConstraints(maxWidth: width, minWidth: width, minHeight: width, maxHeight: width),
              //   children: HomeSelect.values
              //       .map(
              //         (e) => Tooltip(
              //           decoration: BoxDecoration(color: themeData.colorScheme.background, borderRadius: borderRadius),
              //           richMessage: TextSpan(text: e.label, style: const TextStyle(color: Colors.white)),
              //           child: Icon(e.icon),
              //         ),
              //       )
              //       .toList(),
              // ).addPadding(!isBiblioteca ? const EdgeInsets.symmetric(horizontal: 8) : const EdgeInsets.only(right: 8)),

              if (!isBiblioteca && !disableButton)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ToggleButtons(
                    onPressed: _onPressedTypeEvent,
                    borderRadius: borderRadius,
                    isSelected: _typeEventSelect,
                    constraints: BoxConstraints(maxWidth: width, minWidth: width, minHeight: width, maxHeight: width),
                    children: TypeEvent.values
                        .map((event) => Tooltip(
                              decoration: BoxDecoration(color: themeData.colorScheme.background, borderRadius: borderRadius),
                              richMessage: TextSpan(text: event.title, style: const TextStyle(color: Colors.white)),
                              child: Icon(event.iconData),
                            ))
                        .toList(),
                  ),
                ),

              // ToggleButtons(
              //   onPressed: _onModeView,
              //   borderRadius: borderRadius,
              //   constraints: BoxConstraints(maxWidth: width * 1.2, minWidth: width * 1.2, minHeight: width, maxHeight: width),
              //   isSelected: _modeView,
              //   children: _modeView
              //       .mapIndexed(
              //         (index, e) => Tooltip(
              //           decoration: BoxDecoration(color: themeData.colorScheme.background, borderRadius: borderRadius),
              //           richMessage: TextSpan(text: ModeView.values.elementAt(index).label, style: const TextStyle(color: Colors.white)),
              //           child: _GridViewContainer(
              //             mode: ModeView.values.elementAt(index),
              //           ),
              //         ),
              //       )
              //       .toList(),
              // ),
              // Tooltip(
              //   decoration: BoxDecoration(color: themeData.colorScheme.background, borderRadius: borderRadius),
              //   richMessage: TextSpan(text: hiveController.modeView.label, style: const TextStyle(color: Colors.white)),
              //   child: IconButton.outlined(
              //     onPressed: () async {
              //       final mode = hiveController.modeView;
              //       switch (mode) {
              //         case ModeView.GRID_2X2:
              //           await hiveController.setModeView(ModeView.GRID_3X3);
              //           break;
              //         case ModeView.GRID_3X3:
              //           await hiveController.setModeView(ModeView.GRID_2X2);
              //           break;
              //         case ModeView.PAGEVIEW:
              //           await hiveController.setModeView(ModeView.GRID_2X2);
              //           break;
              //       }
              //     },
              //     iconSize: 18,
              //     enableFeedback: true,
              //     constraints: BoxConstraints(maxWidth: width, minWidth: width, minHeight: width, maxHeight: width),
              //     style: ButtonStyle(shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: borderRadius))),
              //     icon: _GridViewContainer(mode: hiveController.modeView),
              //   ).addPadding(isHome ? const EdgeInsets.only(right: 8) : EdgeInsets.zero),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// class _GridViewContainer extends StatelessWidget {
//   const _GridViewContainer({required this.mode});

//   final ModeView mode;

//   @override
//   Widget build(BuildContext context) {
//     double spacing;
//     double runSpacing;
//     final borderRadius = BorderRadius.circular(8);

//     final themeData = context.themeData;
//     final List<Widget> children = [];

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         switch (mode) {
//           case ModeView.GRID_2X2:
//             spacing = 3.5;
//             runSpacing = 4;
//             for (int i = 0; i < 4; i++) {
//               children.add(
//                 Tooltip(
//                   decoration: BoxDecoration(color: themeData.colorScheme.background, borderRadius: borderRadius),
//                   richMessage: TextSpan(text: mode.label, style: const TextStyle(color: Colors.white)),
//                   child: Container(
//                     height: 8,
//                     width: 8.9,
//                     decoration: BoxDecoration(
//                       color: themeData.colorScheme.primary,
//                       borderRadius: BorderRadius.circular(1),
//                     ),
//                   ),
//                 ),
//               );
//             }
//             break;
//           case ModeView.GRID_3X3:
//             spacing = 3.5;
//             runSpacing = 4;
//             for (int i = 0; i < 6; i++) {
//               children.add(
//                 Tooltip(
//                   decoration: BoxDecoration(color: themeData.colorScheme.background, borderRadius: borderRadius),
//                   richMessage: TextSpan(text: mode.label, style: const TextStyle(color: Colors.white)),
//                   child: Container(
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: themeData.colorScheme.primary,
//                       borderRadius: BorderRadius.circular(1),
//                     ),
//                     width: 7.2,
//                   ),
//                 ),
//               );
//             }
//             break;
//           case ModeView.PAGEVIEW:
//             spacing = 0;
//             runSpacing = 0;
//             children.add(
//               Container(
//                 height: 20,
//                 width: 20,
//                 decoration: BoxDecoration(color: themeData.colorScheme.primary, borderRadius: BorderRadius.circular(1)),
//               ),
//             );
//             break;
//         }
//         return Padding(
//           padding: EdgeInsets.all(mode == ModeView.GRID_2X2 ? constraints.maxWidth * .15 : constraints.maxWidth * .1),
//           child: Wrap(
//             spacing: spacing,
//             runSpacing: runSpacing,
//             children: children,
//           ),
//         );
//       },
//     );
//   }
// }
