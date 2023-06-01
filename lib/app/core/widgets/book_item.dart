import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/constants/app.dart';
import 'package:leviathan_app/app/core/constants/grid.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/repositories/library_repository.dart';
import 'package:leviathan_app/app/core/routes/routes.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:leviathan_app/app/core/utils/book_utils.dart';
import 'package:leviathan_app/app/core/utils/is_selected.dart';
import 'package:leviathan_app/app/core/widgets/open_container_wrapper.dart';
import 'package:leviathan_app/app/ui/home/widgets/scope.dart';
import 'package:provider/provider.dart';

class BookItem extends StatelessWidget {
  final Book book;
  final bool isBiblioteca;
  const BookItem({
    super.key,
    this.isBiblioteca = false,
    required this.book,
    this.persistentFooterButtons,
  });

  final List<Widget>? persistentFooterButtons;

  @override
  Widget build(BuildContext context) {
    final hiveController = context.watch<HiveController>();
    final imageUrl = book.largeImage ?? book.mediumImage ?? book.originalImage;
    final themeData = context.themeData;
    final textTheme = themeData.textTheme;

    final isSmall = hiveController.modeView == ModeView.GRID_3X3;

    final borderRadius = BorderRadius.circular(6);
    final library = context.watch<LibraryRepository>();
    final isFavorite = library.contains(book: book);
    final isSelected = context.watch<IsSelected>();
    final homeScope = HomeScope.of(context);

    final selected = isSelected.contains(book.id);

    return AnimatedContainer(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: selected ? Border.all(width: 1.8, color: Colors.white) : null,
      ),
      duration: const Duration(milliseconds: 300),
      child: OpenContainerWrapper(
        routeName: RouteName.BOOKINFO,
        closedElevation: 0,
        openElevation: 0,
        clipBehavior: Clip.hardEdge,
        openColor: themeData.cardColor,
        closedColor: themeData.cardColor,
        borderRadius: BorderRadius.circular(4),
        useRootNavigator: true,
        transitionDuration: const Duration(milliseconds: 500),
        highlightColor: themeData.highlightColor,
        tappable: false,
        routeSettings: RouteSettings(arguments: {'book': book}),
        closedChild: (context) => Stack(
          fit: StackFit.expand,
          children: [
            ShaderMask(
              blendMode: BlendMode.srcOver,
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black38.withOpacity(0.75),
                  ],
                  stops: const [0.0, .9],
                ).createShader(bounds);
              },
              child: CachedNetworkImage(
                progressIndicatorBuilder: (context, url, progress) => const SizedBox.shrink(),
                imageUrl: imageUrl,
                cacheManager: App.BOOKITEMCACHE,
                memCacheHeight: 350,
                memCacheWidth: 250,
                // alignment: Alignment.topCenter,
                fit: BoxFit.cover,
              ),
            ),
            if (isFavorite && !isBiblioteca)
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isSmall ? 4 : 6),
                    color: themeData.colorScheme.surface,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                    child: Text(
                      'Na Biblioteca',
                      style: textTheme.labelSmall?.copyWith(fontSize: isSmall ? 7.0 : 8.5),
                    ),
                  ),
                ),
              ),
            Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(fontSize: isSmall ? 12.2 : 14, fontWeight: FontWeight.bold),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                enableFeedback: true,
                onLongPress: () async {
                  if (!homeScope.activeOverflow && isBiblioteca) {
                    homeScope.activeOverFlowWidget(true, [...?persistentFooterButtons]);
                    isSelected.add(book.id);
                  } else {
                    if (isFavorite) {
                      final result = await BookUtils.bibliotecaAddOrRemove(context, [book]);
                      if (result == true) library.remove(book: book);
                      return;
                    }
                    library.add(book: book.copyWith(createdAt: DateTime.now()));
                  }
                },
                onTap: () {
                  if (isSelected.isEmpty && isBiblioteca) {
                    if (isSelected.isNotEmpty) isSelected.clear();
                    OpenContainerWrapper.action(context);
                  } else if (isBiblioteca) {
                    isSelected.add(book.id);
                    if (isSelected.isEmpty) {
                      isSelected.cache = null;
                      homeScope.activeOverFlowWidget(false);
                    }
                  } else {
                    OpenContainerWrapper.action(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class ParallaxFlowDelegate extends FlowDelegate {
//   ParallaxFlowDelegate({
//     required this.scrollable,
//     required this.listItemContext,
//     required this.backgroundImageKey,
//   }) : super(repaint: scrollable.position);

//   final ScrollableState scrollable;
//   final BuildContext listItemContext;
//   final GlobalKey backgroundImageKey;

//   @override
//   BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
//     return BoxConstraints.tightFor(width: constraints.maxWidth, height: constraints.maxHeight);
//   }

//   @override
//   void paintChildren(FlowPaintingContext context) {
//     final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
//     final listItemBox = listItemContext.findRenderObject() as RenderBox;
//     final listItemOffset = listItemBox.localToGlobal(listItemBox.size.topCenter(Offset.zero), ancestor: scrollableBox);

//     final viewportDimension = scrollable.position.viewportDimension;
//     final scrollFraction = (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);
//     final verticalAlignment = Alignment(0.0, scrollFraction * 10 - 1);

//     final backgroundSize = (backgroundImageKey.currentContext!.findRenderObject() as RenderBox).size;
//     final listItemSize = context.size;
//     final childRect = verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

//     context.paintChild(
//       0,
//       transform: Transform.translate(offset: Offset(0.0, childRect.top)).transform,
//     );
//   }

//   @override
//   bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
//     return scrollable != oldDelegate.scrollable ||
//         listItemContext != oldDelegate.listItemContext ||
//         backgroundImageKey != oldDelegate.backgroundImageKey;
//   }
// }
