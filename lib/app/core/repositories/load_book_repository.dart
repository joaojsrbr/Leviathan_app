import 'dart:async';

import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/constants/fonte.dart';
import 'package:leviathan_app/app/core/interfaces/success.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/models/chapter.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:loading_more_list/loading_more_list.dart';

import 'book_repository.dart';

class LoadBookRepository extends ChangeNotifier {
  final List<ILoadBook> _lista = [];

  late final HiveController _hiveController;

  StreamSubscription? _subscription;

  late ILoadBook repository;

  bool _error = false;

  LoadBookRepository(this._hiveController) {
    _lista.addAll([ILoadBook.neox(), ILoadBook.mangabtt()]);
    repository = _lista.firstWhere(_test);
    _subscription = repository.rebuild.listen(_listen);
    repository.setType = _hiveController.type;
    repository.refresh(true);
  }

  LoadBookRepository.empty(Fonte fonte) {
    _lista.addAll([ILoadBook.neox(), ILoadBook.mangabtt()]);
    repository = _lista.firstWhere((element) => element.fonte == fonte);
  }

  void _listen(LoadingMoreBase<Book> event) {
    final isTrue = event.indicatorStatus == IndicatorStatus.error || event.indicatorStatus == IndicatorStatus.fullScreenError;
    if (isTrue) {
      if (_error) return;
      _error = true;
      notifyListeners();
    } else {
      if (!_error) return;
      _error = false;
      notifyListeners();
    }
  }

  void switchRepository() {
    _subscription?.cancel();

    repository = _lista.firstWhere(_test);
    _subscription = repository.rebuild.listen(_listen);
    notifyListeners();
  }

  Future<Result<Book>> bookInfo(Book book) async {
    final repository = _lista.firstWhere((element) => element.fonte == book.fonte);
    return await repository.bookInfo(book);
  }

  Future<Result<List<String>>> getContent(Chapter chapter) async {
    final repository = _lista.firstWhere((element) => element.fonte == chapter.fonte);
    return await repository.getContent(chapter);
  }

  // Future<Result<Map<Fonte, List<Book>>>> searchAllRepository(String title) async {
  //   final Map<Fonte, List<Book>> map = {};
  //   final futures = _lista.map((e) => e.getURLByTitle(title));

  //   final urls = (await Future.wait(futures)).map((e) => );
  // }

  Future<String> getURLByTitle(String title, Fonte fonte) async {
    final repository = _lista.firstWhere((element) => element.fonte == fonte);
    return await repository.getURLByTitle(title);
  }

  @override
  void dispose() {
    for (final repository in _lista) {
      repository.dispose();
    }
    _subscription?.cancel();
    repository.dispose();
    super.dispose();
  }

  bool get error => _error;

  bool get disableButton => <Fonte>[Fonte.MANGA_BTT].contains(_hiveController.fonte) || _error;

  bool _test(ILoadBook element) => element.fonte == _hiveController.fonte;
}
