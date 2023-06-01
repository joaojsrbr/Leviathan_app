import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/core/widgets/emoticons.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

Widget indicatorBuilder(BuildContext context, IndicatorStatus status) {
  Widget widget;

  switch (status) {
    case IndicatorStatus.none:
      widget = const _NoneWidget();
      break;
    case IndicatorStatus.loadingMoreBusying:
      widget = const _LoadingMoreBusyingWidget();
      break;
    case IndicatorStatus.fullScreenBusying:
      widget = const _FullScreenBusyingWidget();
      break;
    case IndicatorStatus.error:
      widget = const _ErrorWidget();
      break;
    case IndicatorStatus.fullScreenError:
      widget = const _FullScreenErrorWidget();
      break;
    case IndicatorStatus.noMoreLoad:
      widget = const _NoMoreLoadWidget();
      break;
    case IndicatorStatus.empty:
      widget = const _EmptyWidget();
      break;
    default:
      widget =const _DefaultWidget();
      break;
  }
  return _StatusNotifier(
    status: status,
    child: widget,
  );
}

class _StatusNotifier extends InheritedWidget {
  final IndicatorStatus status;
  const _StatusNotifier({required super.child, required this.status});

  static _StatusNotifier? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_StatusNotifier>();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(EnumProperty<IndicatorStatus>('IndicatorStatus', status, defaultValue: IndicatorStatus.none));
  }

  // ignore: unused_element
  static _StatusNotifier of(BuildContext context) {
    final _StatusNotifier? result = maybeOf(context);
    assert(result != null, 'No _StatusNotifier found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_StatusNotifier oldWidget) => status != oldWidget.status;
}

class _DefaultWidget extends StatelessWidget {
  const _DefaultWidget();
  @override
  Widget build(BuildContext context) {
    final isSliver = context.findAncestorWidgetOfExactType<CustomScrollView>() != null;
    Widget widget = const SizedBox.shrink();
    if (isSliver) widget = SliverToBoxAdapter(child: widget);
    return widget;
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    final isSliver = context.findAncestorWidgetOfExactType<CustomScrollView>() != null;

    Widget child = const SizedBox.shrink();
    if (isSliver) child = SliverToBoxAdapter(child: child);
    return child;
  }
}

class _NoMoreLoadWidget extends StatelessWidget {
  const _NoMoreLoadWidget();

  @override
  Widget build(BuildContext context) {
    final isSliver = context.findAncestorWidgetOfExactType<CustomScrollView>() != null;
    final size = context.mediaQuerySize;
    Widget child = SizedBox(
      height: size.height * .06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(padding: EdgeInsets.all(8.0), child: Icon(MdiIcons.alertCircleOutline)),
          Text('Última página', style: Theme.of(context).textTheme.titleMedium)
        ],
      ),
    );
    if (isSliver) child = SliverToBoxAdapter(child: child);
    return child;
  }
}

class _FullScreenErrorWidget extends StatelessWidget {
  const _FullScreenErrorWidget();

  @override
  Widget build(BuildContext context) {
    final isSliver = context.findAncestorWidgetOfExactType<CustomScrollView>() != null;

    Widget child = const Center(child: EmoticonsView(text: 'Error'));
    if (isSliver) child = SliverFillRemaining(child: child);
    return child;
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget();

  @override
  Widget build(BuildContext context) {
    final isSliver = context.findAncestorWidgetOfExactType<CustomScrollView>() != null;
    final size = context.mediaQuerySize;
    Widget child = SizedBox(
      height: size.height * .06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(padding: EdgeInsets.all(8.0), child: Icon(MdiIcons.alertCircleOutline)),
          Text('Última página', style: Theme.of(context).textTheme.titleMedium)
        ],
      ),
    );
    if (isSliver) child = SliverToBoxAdapter(child: child);
    return child;
  }
}

class _NoneWidget extends StatelessWidget {
  const _NoneWidget();

  @override
  Widget build(BuildContext context) {
    final isSliver = context.findAncestorWidgetOfExactType<CustomScrollView>() != null;

    Widget child = const SizedBox.shrink();
    if (isSliver) child = SliverToBoxAdapter(child: child);
    return child;
  }
}

class _LoadingMoreBusyingWidget extends StatelessWidget {
  const _LoadingMoreBusyingWidget();

  @override
  Widget build(BuildContext context) {
    // if (isSliver) child = SliverToBoxAdapter(child: child);
    return const _BuildCircularWidget();
  }
}

class _FullScreenBusyingWidget extends StatelessWidget {
  const _FullScreenBusyingWidget();

  @override
  Widget build(BuildContext context) {
    final isSliver = context.findAncestorWidgetOfExactType<CustomScrollView>() != null;

    Widget child = const _BuildCircularWidget();
    if (isSliver) child = SliverFillRemaining(child: child);
    return child;
  }
}

class _BuildCircularWidget extends StatelessWidget {
  const _BuildCircularWidget();

  @override
  Widget build(BuildContext context) {
    final size = context.mediaQuerySize;

    return SizedBox(
      height: size.height * .15,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LoadingAnimationWidget.staggeredDotsWave(
          //   color: Theme.of(context).colorScheme.primary,
          //   size: height / 2,
          // ),
          CircularProgressIndicator.adaptive(),
        ],
      ),
    );
  }
}
