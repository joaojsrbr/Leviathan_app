import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class OpenContainerWrapper<T> extends OpenContainer<T> {
  OpenContainerWrapper({
    WidgetBuilder? page,
    VoidCallback? onLongPress,
    VoidCallback? onTap,
    Color? highlightColor,
    BorderRadius? borderRadius,
    Color? splashColor,
    String? routeName,
    VoidCallback? onDoubleTap,
    required WidgetBuilder closedChild,
    super.transitionType = ContainerTransitionType.fade,
    super.key,
    super.tappable = true,
    super.clipBehavior = Clip.antiAlias,
    super.useRootNavigator = true,
    super.transitionDuration = const Duration(milliseconds: 1400),
    super.closedColor,
    super.onClosed,
    super.openColor,
    super.openElevation,
    super.routeSettings,
    super.closedElevation,
  }) : super(
          closedShape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(0)),
          openShape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(0)),
          closedBuilder: (context, action) {
            return _OpenContainerInherited(
              action: action,
              child: Builder(builder: (context) {
                return tappable
                    ? InkWell(
                        autofocus: true,
                        enableFeedback: true,
                        onDoubleTap: onDoubleTap,
                        splashColor: splashColor,
                        highlightColor: highlightColor,
                        borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(8)),
                        onLongPress: onLongPress,
                        onTap: () => OpenContainerWrapper.action(context),
                        child: closedChild.call(context),
                      )
                    : closedChild.call(context);
              }),
            );
          },
          openBuilder: (context, closedContainer) {
            Widget nPage;

            if (page != null) {
              nPage = page.call(context);
            } else if (routeName != null) {
              final mtApp = context.findAncestorWidgetOfExactType<MaterialApp>();
              assert(mtApp != null);

              final Map<String, Widget Function(BuildContext)> routes = mtApp!.routes!;

              assert(routes.containsKey(routeName));

              nPage = routes[routeName]!(context);
            } else {
              nPage = const Scaffold(body: Center(child: Icon(MdiIcons.alert)));
            }

            return _OpenContainerInherited(closedContainer: closedContainer, child: nPage);
          },
        );

  static void action(BuildContext context) => _OpenContainerInherited.of(context).action?.call();

  static void closedContainer(BuildContext context) => _OpenContainerInherited.of(context).closedContainer?.call();
}

class _OpenContainerInherited extends InheritedWidget {
  const _OpenContainerInherited({
    required super.child,
    this.action,
    this.closedContainer,
  });
  final void Function()? action;
  final void Function()? closedContainer;
  static _OpenContainerInherited? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_OpenContainerInherited>();

  static _OpenContainerInherited of(BuildContext context) {
    final _OpenContainerInherited? result = maybeOf(context);
    assert(result != null, 'No _OpenContainerInherited found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_OpenContainerInherited oldWidget) => false;
}
