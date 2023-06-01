import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/models/chapter.dart';

class BookInfoScope extends InheritedWidget {
  const BookInfoScope({
    super.key,
    required super.child,
    required this.book,
    required this.chapterSearch,
    required this.onExpandedSinopse,
    required this.onChapterBottomSheet,
    required this.isLoadingChapters,
    required this.isExpanded,
  });

  final Book book;
  final TextEditingController chapterSearch;
  final void Function() onExpandedSinopse;
  final void Function(BuildContext context, Chapter chapter) onChapterBottomSheet;
  final bool isLoadingChapters;
  final bool isExpanded;

  static BookInfoScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BookInfoScope>();
  }

  static BookInfoScope of(BuildContext context) {
    final BookInfoScope? result = maybeOf(context);
    assert(result != null, 'No BookInfoScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(BookInfoScope oldWidget) =>
      book != oldWidget.book || isLoadingChapters != oldWidget.isLoadingChapters || isExpanded != oldWidget.isExpanded;
}

class ChapterScope extends InheritedWidget {
  const ChapterScope({
    super.key,
    required this.chapter,
    required this.chapters,
    required this.book,
    required this.index,
    required super.child,
  });

  final Chapter chapter;
  final Book book;
  final int index;

  final List<Chapter> chapters;

  static ChapterScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ChapterScope>();
  }

  static ChapterScope of(BuildContext context) {
    final ChapterScope? result = maybeOf(context);
    assert(result != null, 'No ChapterScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ChapterScope oldWidget) => book != oldWidget.book || index != oldWidget.index;
}
