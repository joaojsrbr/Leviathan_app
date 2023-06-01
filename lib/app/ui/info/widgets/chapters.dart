import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/list_extensions.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:leviathan_app/app/ui/info/view/info_view.dart';
import 'package:leviathan_app/app/ui/info/widgets/chapter.dart';
import 'package:leviathan_app/app/ui/info/widgets/scope.dart';
import 'package:provider/provider.dart';

class ChaptersWidget extends StatelessWidget {
  const ChaptersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // final chaptersList = (reverseList ? book.chapters?.reversed.toList() : book.chapters) ?? [];

    final chapterSearch = BookInfoScope.of(context).chapterSearch;

    // final chaptersList = parseChapters ?? [];
    // final chaptersList = (reverseList ? parseChapters?.reversed.toList() : parseChapters) ?? [];
    final book = BookInfoScope.of(context).book;
    final reverseList = context.watch<HiveController>().chaptersReverse;

    return AnimatedBuilder(
      animation: chapterSearch,
      builder: (context, child) {
        // final lista = [if (book.chapters != null) ...book.chapters!];

        // final chaptersList = reverseList ? lista.reversed.toList() : lista;
        final chapters = (book.chapters ?? []).reverse(reverseList);
        final text = chapterSearch.text.trim();

        final filter = chapters.where(
          (element) {
            if (text.isEmpty) return true;

            if (text.contains('-')) {
              final split = text.split('-').map((e) => e.trim()).toList()..removeWhere((element) => element.isEmpty);
              if (split.length < 2) return true;

              final start = double.parse(split.first);
              final end = double.parse(split.last);

              final list = [if (start < end) end else start, if (start < end) start else end];

              final istart = list.first.toInt();
              final iend = list.last.toInt();

              return istart >= element.chapterNumber && iend <= element.chapterNumber;
            }

            if (int.tryParse(text) == null) return true;

            String textReplace = text.replaceAll(RegExp(r'[^0-9].'), '').trim();
            if (textReplace[0] == '.') textReplace = textReplace.replaceFirst('.', '');

            final double value = double.parse(textReplace);

            return element.chapterNumber == value;
          },
        ).mapIndexed((index, chapter) {
          return ChapterScope(
            chapter: chapter,
            key: GlobalKey(),
            index: index,
            book: book,
            chapters: chapters,
            // child: ChapterTitle(key: ValueKey(index)),
            child: const ChapterTitle(),
          );
        });
        return SliverList(
          key: BookInfoPage.CHAPTERS,
          delegate: SliverChildBuilderDelegate(
            (context, index) => filter.elementAt(index),
            childCount: filter.length,
          ),
        );
      },
    );
  }
}
