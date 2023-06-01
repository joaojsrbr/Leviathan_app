import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SharedAxisTransitionPageRouterBuilder<T> extends PageRouteBuilder<T> {
  final String transitionKey;
  final WidgetBuilder? page;
  final String? routeName;
  SharedAxisTransitionPageRouterBuilder({
    this.routeName,
    required this.transitionKey,
    this.page,
    super.fullscreenDialog,
    super.settings,
  }) : super(
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            Widget nPage = const Scaffold(body: Center(child: Icon(MdiIcons.alert)));

            if (page != null) {
              nPage = page.call(context);
            } else if (routeName != null) {
              final mtApp = context.findAncestorWidgetOfExactType<MaterialApp>();
              assert(mtApp != null);

              final Map<String, Widget Function(BuildContext)> routes = mtApp!.routes!;

              assert(routes.containsKey(routeName));

              nPage = routes[routeName]!(context);
            }

            return nPage;
          },
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              key: ValueKey(transitionKey),
              fillColor: context.themeData.cardColor,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.scaled,
              child: child,
            );
          },
        );
}
