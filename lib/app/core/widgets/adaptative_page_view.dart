import 'dart:ui' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const PageScrollPhysics _kPagePhysics = PageScrollPhysics();
final ScrollController _defaultController = ScrollController();

class _SliverFillRemainingWithScrollable extends SingleChildRenderObjectWidget {
  const _SliverFillRemainingWithScrollable({super.child});

  @override
  RenderSliverFillRemainingWithScrollable createRenderObject(BuildContext context) => RenderSliverFillRemainingWithScrollable();
}

class AdaptativePageView extends StatefulWidget {
  AdaptativePageView({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    ScrollController? controller,
    this.physics,
    this.pageSnapping = true,
    this.cacheExtent,
    List<Widget> children = const <Widget>[],
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehavior,
    this.padEnds = true,
  })  : _controller = controller ?? _defaultController,
        childrenDelegate = SliverChildListDelegate(children);

  AdaptativePageView.builder({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    ScrollController? controller,
    this.physics,
    this.pageSnapping = true,
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    int? itemCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.cacheExtent,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehavior,
    this.padEnds = true,
  })  : _controller = controller ?? _defaultController,
        childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          findChildIndexCallback: findChildIndexCallback,
          childCount: itemCount,
        );

  AdaptativePageView.custom({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    ScrollController? controller,
    this.physics,
    this.cacheExtent,
    this.pageSnapping = true,
    required this.childrenDelegate,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehavior,
    this.padEnds = true,
  }) : _controller = controller ?? _defaultController;

  final bool allowImplicitScrolling;

  final String? restorationId;

  final ScrollController _controller;

  final double? cacheExtent;

  final Axis scrollDirection;

  final bool reverse;

  final ScrollPhysics? physics;

  final bool pageSnapping;

  final SliverChildDelegate childrenDelegate;

  final DragStartBehavior dragStartBehavior;

  final Clip clipBehavior;

  final ScrollBehavior? scrollBehavior;

  final bool padEnds;

  @override
  State<AdaptativePageView> createState() => _AdaptativePageViewState();
}

class _AdaptativePageViewState extends State<AdaptativePageView> {
  AxisDirection _getDirection(BuildContext context) {
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        assert(debugCheckHasDirectionality(context));
        final TextDirection textDirection = Directionality.of(context);
        final AxisDirection axisDirection = textDirectionToAxisDirection(textDirection);
        return widget.reverse ? flipAxisDirection(axisDirection) : axisDirection;
      case Axis.vertical:
        return widget.reverse ? AxisDirection.up : AxisDirection.down;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    final ScrollPhysics physics = _ForceImplicitScrollPhysics(
      allowImplicitScrolling: widget.allowImplicitScrolling,
    ).applyTo(
      widget.pageSnapping
          ? _kPagePhysics.applyTo(widget.physics ?? widget.scrollBehavior?.getScrollPhysics(context))
          : widget.physics ?? widget.scrollBehavior?.getScrollPhysics(context),
    );

    final isSliver = context.findAncestorWidgetOfExactType<CustomScrollView>() != null;

    Widget child = Scrollable(
      dragStartBehavior: widget.dragStartBehavior,
      axisDirection: axisDirection,
      controller: widget._controller,
      physics: widget.allowImplicitScrolling && widget.scrollDirection == Axis.vertical ? const ClampingScrollPhysics() : physics,
      restorationId: widget.restorationId,
      scrollBehavior: widget.scrollBehavior ?? ScrollConfiguration.of(context),
      viewportBuilder: (BuildContext context, ViewportOffset position) {
        return Viewport(
          cacheExtent: widget.allowImplicitScrolling ? widget.cacheExtent ?? 1.0 : 0.0,
          cacheExtentStyle: CacheExtentStyle.viewport,
          axisDirection: axisDirection,
          offset: position,
          clipBehavior: widget.clipBehavior,
          slivers: <Widget>[
            _CustomFillViewport(
              // viewportFraction: (widget._controller.position.viewportDimension as double?) ?? 1.0,
              padEnds: widget.padEnds,
              delegate: widget.childrenDelegate,
            ),
          ],
        );
      },
    );

    if (isSliver) child = _SliverFillRemainingWithScrollable(child: child);

    return child;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(EnumProperty<Axis>('scrollDirection', widget.scrollDirection));
    description.add(FlagProperty('reverse', value: widget.reverse, ifTrue: 'reversed'));
    description.add(DiagnosticsProperty<ScrollPhysics>('physics', widget.physics, showName: false));
    description.add(FlagProperty('pageSnapping', value: widget.pageSnapping, ifFalse: 'snapping disabled'));
    description.add(FlagProperty('allowImplicitScrolling', value: widget.allowImplicitScrolling, ifTrue: 'allow implicit scrolling'));
  }
}

class _CustomFillViewport extends StatelessWidget {
  const _CustomFillViewport({
    required this.delegate,
    this.padEnds = true,
    this.viewportFraction = 1.0,
  }) : assert(viewportFraction > 0.0);

  final double viewportFraction;
  final bool padEnds;

  final SliverChildDelegate delegate;

  @override
  Widget build(BuildContext context) {
    return _SliverFractionalPadding(
      viewportFraction: padEnds ? math.clampDouble(1 - viewportFraction, 0, 1) / 2 : 0,
      sliver: _SliverFillViewportRenderObjectWidget(delegate: delegate),
    );
  }
}

class _SliverFractionalPadding extends SingleChildRenderObjectWidget {
  const _SliverFractionalPadding({
    this.viewportFraction = 0,
    Widget? sliver,
  })  : assert(viewportFraction >= 0),
        assert(viewportFraction <= 0.5),
        super(child: sliver);

  final double viewportFraction;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSliverFractionalPadding(viewportFraction: viewportFraction);

  @override
  void updateRenderObject(BuildContext context, _RenderSliverFractionalPadding renderObject) {
    renderObject.viewportFraction = viewportFraction;
  }
}

class _RenderSliverFractionalPadding extends RenderSliverEdgeInsetsPadding {
  _RenderSliverFractionalPadding({
    double viewportFraction = 0,
  })  : assert(viewportFraction <= 0.5),
        assert(viewportFraction >= 0),
        _viewportFraction = viewportFraction;

  SliverConstraints? _lastResolvedConstraints;

  double get viewportFraction => _viewportFraction;
  double _viewportFraction;
  set viewportFraction(double newValue) {
    if (_viewportFraction == newValue) {
      return;
    }
    _viewportFraction = newValue;
    _markNeedsResolution();
  }

  @override
  EdgeInsets? get resolvedPadding => _resolvedPadding;
  EdgeInsets? _resolvedPadding;

  void _markNeedsResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  void _resolve() {
    if (_resolvedPadding != null && _lastResolvedConstraints == constraints) return;

    final double paddingValue = constraints.viewportMainAxisExtent * viewportFraction;
    _lastResolvedConstraints = constraints;
    switch (constraints.axis) {
      case Axis.horizontal:
        _resolvedPadding = EdgeInsets.symmetric(horizontal: paddingValue);
      case Axis.vertical:
        _resolvedPadding = EdgeInsets.symmetric(vertical: paddingValue);
    }

    return;
  }

  @override
  void performLayout() {
    _resolve();
    super.performLayout();
  }
}

class _SliverFillViewportRenderObjectWidget extends SliverMultiBoxAdaptorWidget {
  const _SliverFillViewportRenderObjectWidget({required super.delegate});

  @override
  SliverMultiBoxAdaptorElement createElement() => SliverMultiBoxAdaptorElement(this, replaceMovedChildren: true);

  @override
  RenderSliverList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context as SliverMultiBoxAdaptorElement;
    return RenderSliverList(childManager: element);
    // final SliverMultiBoxAdaptorElement element = context as SliverMultiBoxAdaptorElement;
    // return RenderSliverFillViewport(childManager: element, viewportFraction: viewportFraction);
  }
}

class _ForceImplicitScrollPhysics extends ScrollPhysics {
  const _ForceImplicitScrollPhysics({required this.allowImplicitScrolling, super.parent});

  @override
  _ForceImplicitScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _ForceImplicitScrollPhysics(
      allowImplicitScrolling: allowImplicitScrolling,
      parent: buildParent(ancestor),
    );
  }

  @override
  final bool allowImplicitScrolling;
}
