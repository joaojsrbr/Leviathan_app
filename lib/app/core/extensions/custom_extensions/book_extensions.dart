import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/repositories/library_repository.dart';
import 'package:provider/provider.dart';

extension BookExtensions on Book {
  Book replace(Book? newBook) {
    return copyWith.call(
      id: newBook?.id,
      title: newBook?.title,
      url: newBook?.url,
      originalImage: newBook?.originalImage,
      mediumImage: newBook?.mediumImage,
      largeImage: newBook?.largeImage,
      fonte: newBook?.fonte,
      createdAt: newBook?.createdAt,
      updatedAt: newBook?.updatedAt,
      type: newBook?.type,
      lastChapter: newBook?.lastChapter,
      sinopse: newBook?.sinopse,
      status: newBook?.status,
      autor: newBook?.autor,
      score: newBook?.score,
      tags: newBook?.tags,
      // chapters: newBook?.chapters,
    );
  }
}

extension BookNullExtensions on Book? {
  Book? getBookInDatabase(BuildContext context) => context.read<LibraryRepository>().getBookNull(this?.id);

  Book? replace(Book? newBook) {
    return this?.copyWith.call(
          data: newBook?.data,
          id: newBook?.id,
          title: newBook?.title,
          url: newBook?.url,
          originalImage: newBook?.originalImage,
          mediumImage: newBook?.mediumImage,
          largeImage: newBook?.largeImage,
          fonte: newBook?.fonte,
          createdAt: newBook?.createdAt,
          updatedAt: newBook?.updatedAt,
          type: newBook?.type,
          lastChapter: newBook?.lastChapter,
          sinopse: newBook?.sinopse,
          status: newBook?.status,
          autor: newBook?.autor,
          score: newBook?.score,
          tags: newBook?.tags,
          chapters: newBook?.chapters,
        );
  }
}
