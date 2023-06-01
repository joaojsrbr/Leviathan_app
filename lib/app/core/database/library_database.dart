import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/list_extensions.dart';
import 'package:leviathan_app/app/core/interfaces/hive_service.dart';
import 'package:leviathan_app/app/core/interfaces/success.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/models/chapter.dart';

part 'library_database_impl.dart';

abstract interface class LibraryDatabase {
  Future<Result> getAll();

  Future<Result> remove({Book? book, Chapter? chapter});

  Future<Result> add({Book? book, Chapter? chapter});

  Future<Result> update({Book? book, Chapter? chapter});

  Future<Result> addAll({List<Book>? books, List<Chapter>? chapters});

  Future<Result> removeAll({List<Book>? books, List<Chapter>? chapters});

  bool contains({Book? book, Chapter? chapter});

  bool bookTest(Book element, Book book);

  bool chapterTest(Chapter element, Chapter chapter);
}
