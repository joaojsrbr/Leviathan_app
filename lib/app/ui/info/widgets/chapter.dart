import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/core/repositories/library_repository.dart';
import 'package:leviathan_app/app/core/widgets/dismissible/my_dismissible.dart';
import 'package:leviathan_app/app/core/widgets/open_container_wrapper.dart';
import 'package:leviathan_app/app/ui/info/widgets/scope.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ChapterTitle extends StatelessWidget {
  const ChapterTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final ChapterScope chapterScope = ChapterScope.of(context);
    Widget? trailing;
    Widget? subtitle;
    final library = context.watch<LibraryRepository>();
    final chapter = library.getChapter(chapterScope.chapter);
    final chapters = chapterScope.chapters;
    final index = ChapterScope.of(context).index;
    final book = chapterScope.book;

    final themeData = context.themeData;
    final textTheme = themeData.textTheme;
    final color = (chapter.read) ? textTheme.labelMedium?.color?.withOpacity(0.4) : textTheme.labelMedium?.color;

    final style = textTheme.labelMedium?.copyWith(color: color) ?? const TextStyle();

    if (chapter.readPercent != null) {
      final percent = (chapter.readPercent! * 100).toStringAsFixed(2);
      trailing = AnimatedDefaultTextStyle(style: style, duration: const Duration(milliseconds: 500), child: Text('$percent %'));
    }

    if (chapter.diffTime != null && chapter.chapterDescription == null) {
      subtitle = AnimatedDefaultTextStyle(style: style, duration: const Duration(milliseconds: 500), child: Text(chapter.diffTime!));
    }

    return MyDismissible(
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (!library.contains(chapter: chapter)) {
            library.add(chapter: chapter.copyWith(read: true, readPercent: 1.0, updatedAt: DateTime.now()));
          } else {
            library.update(chapter: chapter.copyWith(read: true, readPercent: 1.0, updatedAt: DateTime.now()));
          }
        } else if (direction == DismissDirection.endToStart && library.contains(chapter: chapter)) {
          library.remove(chapter: chapter);
        }

        return true;
      },
      dismissThresholds: const {DismissDirection.endToStart: 0.5, DismissDirection.startToEnd: 0.5},
      resizeDuration: const Duration(milliseconds: 600),
      radius: 20,
      background: Container(
        alignment: Alignment.centerLeft,
        decoration: const BoxDecoration(color: Colors.green),
        padding: const EdgeInsets.only(left: 20.0),
        child: const Icon(MdiIcons.eyePlus, color: Colors.white),
      ),
      secondaryBackground: Container(
        decoration: const BoxDecoration(color: Colors.red),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(MdiIcons.eyeRemove, color: Colors.white),
      ),
      key: ValueKey(chapter.id),
      child: OpenContainerWrapper(
        closedColor: Colors.transparent,
        closedElevation: 0,
        openElevation: 0,
        openColor: themeData.cardColor,
        borderRadius: BorderRadius.zero,
        routeName: '/read',
        tappable: false,
        useRootNavigator: true,
        routeSettings: RouteSettings(arguments: {'chapter': chapter, 'lista': chapters, 'index': index, 'book': book}),
        closedChild: (context) => ListTile(
          dense: true,
          onTap: () => OpenContainerWrapper.action(context),
          onLongPress: () => BookInfoScope.of(context).onChapterBottomSheet.call(context, chapter),
          trailing: trailing,
          subtitle: subtitle,
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            style: style,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: chapter.chapterName),
                  if (chapter.chapterVersion != null) const TextSpan(text: ' - '),
                  if (chapter.chapterVersion != null)
                    TextSpan(
                      text: 'v${chapter.chapterVersion!.toStringAsPrecision(1)}',
                      style: TextStyle(color: Colors.orange.shade200),
                    ),
                  if (chapter.chapterFix != null) const TextSpan(text: ' - '),
                  if (chapter.chapterFix != null) const TextSpan(text: 'Fix', style: TextStyle(color: Colors.red)),
                  if (chapter.chapterDescription != null) TextSpan(text: ' - ${chapter.chapterDescription}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
