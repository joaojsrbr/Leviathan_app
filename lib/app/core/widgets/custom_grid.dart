import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class CustomGrid extends StatefulWidget {
  const CustomGrid({
    super.key,
    this.viewportSize,
    required this.children,
    this.crossAxisCount = 2,
    this.itemCount,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.maxItemsPerViewport = 1,
  });

  final Size? viewportSize;

  final int maxItemsPerViewport;

  final ScrollController? controller;

  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  final EdgeInsetsGeometry? padding;

  final ScrollPhysics? physics;

  final bool shrinkWrap;

  final List<Widget> children;

  final int? itemCount;

  final int crossAxisCount;

  @override
  State<CustomGrid> createState() => _CustomGridState();
}

class _CustomGridState extends State<CustomGrid> {
  late List<Widget> _viewports;

  @override
  void initState() {
    _viewports = _generateViewports();
    super.initState();
  }

  List<Widget> _generateViewports() {
    final slicedChildren = widget.children
        //
        .slices(widget.maxItemsPerViewport)
        .toList();

    return List.generate(
      slicedChildren.length,
      (urlsSliceIndex) {
        final childrenSlice = slicedChildren[urlsSliceIndex];

        return _MasonryGrid(
          index: urlsSliceIndex,
          children: childrenSlice,
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant CustomGrid oldWidget) {
    if (oldWidget.crossAxisCount != widget.crossAxisCount || oldWidget.maxItemsPerViewport != widget.maxItemsPerViewport) {
      _viewports = _generateViewports();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GridView.builder(
      physics: widget.physics,
      padding: widget.padding,
      controller: widget.controller,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      shrinkWrap: widget.shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: (widget.viewportSize ?? size).width / (widget.viewportSize ?? size).height,
      ),
      itemCount: _viewports.length,
      itemBuilder: (context, index) => _viewports[index],
    );
  }
}

class _MasonryGrid extends StatefulWidget {
  const _MasonryGrid({
    this.children = const [],
    required this.index,
  });

  final List<Widget> children;
  final int index;

  @override
  State<_MasonryGrid> createState() => _MasonryGridState();
}

class _MasonryGridState extends State<_MasonryGrid> {
  late List<Widget> _rows;

  static const int _maxItemsPerRow = 4;
  static final Random _random = Random(3);

  List<Widget> _generateRows() {
    final slicedChildren = widget.children.slices(_maxItemsPerRow).toList();

    return List.generate(
      slicedChildren.length,
      (childrenSliceIndex) {
        final childrenSlice = slicedChildren[childrenSliceIndex];

        var mainRowChildren = <Widget>[];

        if (childrenSliceIndex.isEven && childrenSlice.length >= 3) {
          mainRowChildren = [
            Expanded(child: childrenSlice[0]),
            Expanded(
              child: Column(
                children: [
                  Expanded(flex: _random.nextInt(2) + 1, child: childrenSlice[1]),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: childrenSlice[2]),
                        if (childrenSlice.length == 4) Expanded(child: childrenSlice[3]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        } else {
          mainRowChildren = List.generate(
            childrenSlice.length,
            (widgetIndex) {
              return Expanded(
                flex: _random.nextInt(2) + 1,
                child: childrenSlice[widgetIndex],
              );
            },
          );
        }

        return Expanded(
          flex: childrenSliceIndex.isOdd ? 1 : _random.nextInt(3) + 1,
          child: Row(children: mainRowChildren),
        );
      },
    );
  }

  @override
  void initState() {
    _rows = _generateRows();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _MasonryGrid oldWidget) {
    if (oldWidget.children != widget.children) _rows = _generateRows();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => Column(children: List.generate(_rows.length, (i) => _rows[i]));
}
