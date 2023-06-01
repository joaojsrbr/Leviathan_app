import 'package:leviathan_app/app/core/models/chapter.dart';

extension ChapterExtensions on Chapter {
  Chapter replace(Chapter? newBook) {
    return copyWith(
      id: newBook?.id,
      read: newBook?.read,
      fonte: newBook?.fonte,
      url: newBook?.url,
      chapterName: newBook?.chapterName,
      readPercent: newBook?.readPercent,
      createdAt: newBook?.createdAt,
      updatedAt: newBook?.updatedAt,
    );
  }
}

extension ChapterNullExtensions on Chapter? {
  Chapter? replace(Chapter? newBook) {
    return this?.copyWith(
      id: newBook?.id,
      read: newBook?.read,
      chapterDescription: newBook?.chapterDescription,
      chapterNumber: newBook?.chapterNumber,
      chapterVersion: newBook?.chapterVersion,
      fonte: newBook?.fonte,
      url: newBook?.url,
      chapterName: newBook?.chapterName,
      readPercent: newBook?.readPercent,
      createdAt: newBook?.createdAt,
      updatedAt: newBook?.updatedAt,
    );
  }
}
