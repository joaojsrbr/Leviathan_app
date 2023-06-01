import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hidable/hidable.dart';

class CustomHidableController extends IHidableController {
  ScrollPosition? get _position {
    if (scrollController.positions.isEmpty && scrollController.hasClients) return null;
    final position = scrollController.positions.firstWhere((element) => element.userScrollDirection != ScrollDirection.idle);
    return position;
    // return scrollController.positions
    //     .where((element) => element.userScrollDirection != ScrollDirection.idle)
    //     .reduce((value, element) => element.userScrollDirection == value.userScrollDirection ? element : value);
  }

  @override
  void listener() {
    if (_position == null) return;
    // scrollController.hasClients;

    // late ScrollPosition p;
    // if (scrollController.positions.length == 1) {
    //   p = scrollController.position;
    // } else {
    //   p = scrollController.positions.where((element) => element.userScrollDirection != ScrollDirection.idle).singleOrNull ??
    //       scrollController.position;
    // }

    // Set "li" by pixels and last offset.
    li = (li + _position!.pixels - lastOffset).clamp(0.0, size);
    lastOffset = _position!.pixels;

    // If scrolled down, size-notifiers value should be zero.
    // Can be imagined as [zero = false] | [one = true].
    if (_position!.axisDirection == AxisDirection.down && _position!.extentAfter == 0.0) {
      if (sizeNotifier.value == 0.0) return;

      sizeNotifier.value = 0.0;
      return;
    }

    // If scrolled up, size-notifiers value should be one.
    // Can be imagined as [zero - false] | [one - true].
    if (_position!.axisDirection == AxisDirection.up && _position!.extentBefore == 0.0) {
      if (sizeNotifier.value == 1.0) return;

      sizeNotifier.value = 1.0;
      return;
    }

    final isZeroValued = li == 0.0 && sizeNotifier.value == 0.0;
    if (isZeroValued || (li == size && sizeNotifier.value == 1.0)) return;

    sizeNotifier.value = sizeFactor();
  }
}
