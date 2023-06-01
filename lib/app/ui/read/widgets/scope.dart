import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReaderController extends ScrollController {}

class ReadScope extends InheritedWidget {
  const ReadScope({
    super.key,
    required super.child,
    required this.loadingMoreWidget,
    required this.lastMaxScrollExtent,
    required this.lastPixels,
    required this.overlayAppBarAnimation,
    required this.overlayBottomBarAnimation,
    required this.content,
    required this.onNotification,
    required this.readerController,
    required this.overlay,
    required this.chapterName,
    required this.onDoubleTapDown,
  });

  final String? chapterName;
  final bool overlay;
  final double? lastMaxScrollExtent;
  final void Function(BuildContext context, TapDownDetails details) onDoubleTapDown;
  final List<Widget> content;
  final Animation<Offset> overlayAppBarAnimation;
  final Animation<Offset> overlayBottomBarAnimation;
  final bool Function(ScrollNotification scrollNotification) onNotification;
  final double? lastPixels;

  final ReaderController readerController;
  final ValueNotifier<bool> loadingMoreWidget;

  static ReadScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ReadScope>();
  }

  double get pixels {
    if (!readerController.position.hasContentDimensions) return 0.0;
    double pixels;
    if (lastPixels != null) {
      pixels = (readerController.position.pixels - lastPixels!);
    } else {
      pixels = readerController.position.pixels;
    }
    return pixels;
  }

  double get maxScrollExtent {
    if (!readerController.position.hasContentDimensions) return 0.0;
    double maxScrollExtent;
    if (lastMaxScrollExtent != null) {
      maxScrollExtent = (readerController.position.maxScrollExtent - lastMaxScrollExtent!);
    } else {
      maxScrollExtent = readerController.position.maxScrollExtent;
    }
    return maxScrollExtent;
  }

  double get percent {
    double percent = (pixels / maxScrollExtent);

    if (percent.isNegative) percent = (1 - -percent);

    return percent;
  }

  static ReadScope of(BuildContext context) {
    final ReadScope? result = maybeOf(context);
    assert(result != null, 'No ReadScope found in context');
    return result!;
  }

  static ValueNotifier<bool> loadingMoreOf(BuildContext context) => of(context).loadingMoreWidget;
  // static ReaderController readerControllerOf(BuildContext context) => of(context).readerController;

  @override
  bool updateShouldNotify(ReadScope oldWidget) =>
      lastMaxScrollExtent != oldWidget.lastMaxScrollExtent ||
      lastPixels != oldWidget.lastPixels ||
      chapterName != oldWidget.chapterName ||
      listEquals(content, oldWidget.content) ||
      overlay != oldWidget.overlay;
}
