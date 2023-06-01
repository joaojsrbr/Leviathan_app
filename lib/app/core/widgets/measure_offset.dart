import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnWidgetOffsetChange = void Function(Offset offset, int index);

class MeasureOffsetRenderObject extends RenderProxyBox {
  Offset? oldOffset;
  int index;
  double? bottomHeight;
  OnWidgetOffsetChange onChange;
  BuildContext context;

  MeasureOffsetRenderObject(
    this.onChange,
    this.index,
    this.context,
    this.bottomHeight,
  );

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = child!.size;
      // child!.layout(constraints, parentUsesSize: true);
      // size = child!.size;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ScrollableState scrollState = Scrollable.of(context);
        Offset atual = Offset(0, scrollState.position.pixels - (bottomHeight ?? 0));
        final Offset offset = localToGlobal(atual);
        onChange(offset, index);
      });
    } else {
      size = constraints.biggest;
    }
  }

  // @override
  // void performLayout() {
  //   super.performLayout();

  //   Offset? newOffset = child?.localToGlobal(Offset.zero);
  //   if (newOffset == oldOffset || newOffset == null) return;

  //   oldOffset = newOffset;
  //   WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newOffset, index));
  // }
}

class MeasureOffset extends SingleChildRenderObjectWidget {
  final OnWidgetOffsetChange onChange;
  final int index;
  final double? bottomHeight;

  const MeasureOffset({
    super.key,
    required this.onChange,
    required this.index,
    this.bottomHeight,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => MeasureOffsetRenderObject(onChange, index, context, bottomHeight);

  @override
  void updateRenderObject(BuildContext context, covariant MeasureOffsetRenderObject renderObject) {
    renderObject.onChange = onChange;
    renderObject.index = index;
    renderObject.context = context;
    renderObject.bottomHeight = bottomHeight;
  }
}
