// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names, constant_identifier_names
part of 'library_database.dart';

class LibraryDatabaseImpl implements LibraryDatabase {
  final Service _service;
  LibraryDatabaseImpl(this._service);

  static const DATABASEBOOKKEY = 'book_database';
  static const DATABASECHAPTERSKEY = 'chapters_database';

  List<Book> _lista = [];
  List<Chapter> _listaChapters = [];

  UnmodifiableListView<Book> get lista => UnmodifiableListView(_lista);

  UnmodifiableListView<Chapter> get listaChapters => UnmodifiableListView(_listaChapters);

  String get _saveBook => lista.map((e) => e.toJson()).toList().encode();
  String get _saveChapter => listaChapters.map((e) => e.toJson()).toList().encode();

  @override
  Future<Result> add({Book? book, Chapter? chapter}) async {
    if (book != null && !contains(book: book)) {
      _lista.add(book);

      await _service.save(DATABASEBOOKKEY, _saveBook, false);
      return const Result.success(true);
    }

    if (chapter != null && !contains(chapter: chapter)) {
      _listaChapters.add(chapter);
      await _service.save(DATABASECHAPTERSKEY, _saveChapter, false);
      return const Result.success(true);
    }

    return const Result.empty();
  }

  _printChapter(String data) {
    final lista = (json.decode(data) as List);
    if (lista.isEmpty) return lista;
    return (json.decode(data) as List).map((e) => Chapter.fromJson(e)).toList();
  }

  _printBook(String data) {
    final lista = (json.decode(data) as List);
    if (lista.isEmpty) return lista;
    return (json.decode(data) as List).map((e) => Book.fromJson(e)).toList();
  }

  @override
  Future<Result> getAll() async {
    final result = json.decode(await _service.load(DATABASEBOOKKEY, '[]', print: _printBook)) as List;
    final result2 = json.decode(await _service.load(DATABASECHAPTERSKEY, '[]', print: _printChapter)) as List;
    _lista = result.map((e) => Book.fromJson(e)).toList();
    _listaChapters = result2.map((e) => Chapter.fromJson(e)).toList();
    return const Result.success(true);
  }

  @override
  Future<Result> remove({Book? book, Chapter? chapter}) async {
    if (book != null && contains(book: book)) {
      _lista.removeWhere((element) => bookTest(element, book));
      await _service.save(DATABASEBOOKKEY, _saveBook, false);
      return const Result.success(true);
    }

    if (chapter != null && contains(chapter: chapter)) {
      _listaChapters.removeWhere((element) => chapterTest(element, chapter));
      await _service.save(DATABASECHAPTERSKEY, _saveChapter, false);
      return const Result.success(true);
    }

    return const Result.empty();
  }

  @override
  bool bookTest(Book element, Book? book) {
    return element.fonte == book?.fonte && element.title.contains(book?.title ?? '') && element.url.contains(book?.url ?? '');
  }

  @override
  bool chapterTest(Chapter element, Chapter chapter) {
    return element.fonte == chapter.fonte && element.chapterName.contains(chapter.chapterName) && element.url.contains(chapter.url);
  }

  @override
  Future<Result> update({Book? book, Chapter? chapter}) async {
    if (book != null) {
      final indexOf = _lista.indexWhere((element) => bookTest(element, book));
      if (indexOf == -1) {
        return Result.failure(Exception('Esta instância não existe'));
      } else {
        _lista[indexOf] = book;
        await _service.save(DATABASEBOOKKEY, _saveBook, false);
        return const Result.success(true);
      }
    }

    if (chapter != null) {
      final indexOf = _listaChapters.indexWhere((element) => chapterTest(element, chapter));
      if (indexOf == -1) {
        return Result.failure(Exception('Esta instância não existe'));
      } else {
        _listaChapters[indexOf] = chapter;
        await _service.save(DATABASECHAPTERSKEY, _saveChapter, false);
        return const Result.success(true);
      }
    }
    return const Result<Book>.empty();
  }

  @override
  Future<Result> addAll({List<Book>? books, List<Chapter>? chapters}) async {
    if (books != null) {
      for (final item in books) {
        if (!contains(book: item)) _lista.add(item);
      }
    }

    if (chapters != null) {
      for (final item in chapters) {
        if (!contains(chapter: item)) _listaChapters.add(item);
      }
    }

    await Future.wait([
      if (chapters != null) _service.save(DATABASECHAPTERSKEY, _saveChapter, false),
      if (books != null) _service.save(DATABASEBOOKKEY, _saveBook, false)
    ]);

    return const Result.success(true);
  }

  @override
  Future<Result> removeAll({List<Book>? books, List<Chapter>? chapters}) async {
    if (books != null) {
      for (final item in books) {
        if (contains(book: item)) _lista.removeWhere((element) => bookTest(element, item));
      }
    }

    if (chapters != null) {
      for (final item in chapters) {
        if (contains(chapter: item)) _listaChapters.removeWhere((element) => chapterTest(element, item));
      }
    }

    await Future.wait([
      if (chapters != null) _service.save(DATABASECHAPTERSKEY, _saveChapter, false),
      if (books != null) _service.save(DATABASEBOOKKEY, _saveBook, false)
    ]);

    return const Result.success(true);
  }

  @override
  bool contains({Book? book, Chapter? chapter}) {
    assert(!(book != null && chapter != null));
    if (book != null) {
      final index = lista.indexWhere((element) => bookTest(element, book));
      return index != -1 ? true : false;
    } else if (chapter != null) {
      final index = listaChapters.indexWhere((element) => chapterTest(element, chapter));
      return index != -1 ? true : false;
    }
    return false;
  }
}
