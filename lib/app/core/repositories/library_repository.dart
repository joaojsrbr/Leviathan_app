import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/database/library_database.dart';
import 'package:leviathan_app/app/core/interfaces/success.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/models/chapter.dart';

class LibraryRepository extends ChangeNotifier implements LibraryDatabase {
  final LibraryDatabaseImpl _db;

  LibraryRepository(this._db);

  UnmodifiableListView<Book> get lista => _db.lista;

  UnmodifiableListView<Chapter> get listaChapters => _db.listaChapters;

  @override
  bool contains({Book? book, Chapter? chapter}) => _db.contains(book: book, chapter: chapter);

  @override
  bool bookTest(Book element, Book? book) => _db.bookTest(element, book);

  UnmodifiableListView<Book> sorted(int Function(Book, Book) compare) {
    return UnmodifiableListView(lista.sorted(compare));
  }

  UnmodifiableListView<Book> sortedBy(int Function(Book, Book) compare) {
    return UnmodifiableListView(lista.sorted(compare));
  }

  @override
  bool chapterTest(Chapter element, Chapter chapter) => _db.chapterTest(element, chapter);

  Book getBook(Book book) {
    final newBook = lista.firstWhereOrNull((element) => bookTest(element, book));

    return book.copyWith.call(
      id: newBook?.id,
      title: newBook?.title,
      url: newBook?.url,
      originalImage: newBook?.originalImage,
      mediumImage: newBook?.mediumImage,
      largeImage: newBook?.largeImage,
      fonte: newBook?.fonte,
      createdAt: newBook?.createdAt,
      updatedAt: newBook?.updatedAt,
    );
  }

  Book? getBookNull(String? id) {
    final newBook = lista.firstWhereOrNull((element) => element.id.contains(id ?? ''));

    return newBook;
  }

  Chapter getChapter(Chapter chapter) {
    final newChapter = listaChapters.firstWhere((element) => chapterTest(element, chapter), orElse: () => chapter);

    return chapter.copyWith(
      read: newChapter.read,
      readPercent: newChapter.readPercent,
      updatedAt: newChapter.updatedAt,
      createdAt: newChapter.createdAt,
    );
  }

  String? getIdBook(Book book) {
    final newBook = lista.firstWhereOrNull((element) => bookTest(element, book));
    return newBook?.id;
  }

  String? getIdChapter(Chapter chapter) {
    final newChapter = listaChapters.firstWhereOrNull((element) => chapterTest(element, chapter));
    return newChapter?.id;
  }

  @override
  Future<Result> addAll({List<Book>? books, List<Chapter>? chapters}) async {
    final result = await _db.addAll(books: books, chapters: chapters);
    notifyListeners();
    return result;
  }

  @override
  Future<Result> removeAll({List<Book>? books, List<Chapter>? chapters}) async {
    final result = await _db.removeAll(books: books, chapters: chapters);
    notifyListeners();
    return result;
  }

  @override
  Future<Result> add({Book? book, Chapter? chapter}) async {
    final result = await _db.add(book: book, chapter: chapter);
    notifyListeners();
    return result;
  }

  @override
  Future<Result> getAll() async {
    return await _db.getAll();
  }

  @override
  Future<Result> remove({Book? book, Chapter? chapter}) async {
    final result = await _db.remove(book: book, chapter: chapter);
    notifyListeners();
    return result;
  }

  @override
  Future<Result> update({Book? book, Chapter? chapter}) async {
    final result = await _db.update(book: book, chapter: chapter);
    notifyListeners();
    return result;
  }
}
