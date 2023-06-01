import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/models/book_categoria.dart';

extension ListExtensions<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = <dynamic>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }

  bool isNM({String? contains}) {
    assert(this is List<String>);
    return (this as List<String>).map((e) => e.toLowerCase()).contains(contains ?? 'novel');
  }

  // Caso o indice seja -1 ele irá adicionar na lista o elemento, caso contrario ele faz o update no elemento
  void replaceOrAddWhere({required bool Function(E element) test, required E replaceWith}) {
    final int index = indexWhere(test);

    if (index != -1) {
      this[index] = replaceWith;
    } else {
      add(replaceWith);
    }
  }

  //   Iterable<R> mapIndexed<R>(R Function(int index, E element) convert) sync* {
  //   for (var index = 0; index < length; index++) {
  //     yield convert(index, this[index]);
  //   }
  // }

  List<E> reverse(bool condition) => condition ? reversed.toList() : this;

  int indexTypeOf<S extends Object>({Type? type}) => indexWhere((element) => element.runtimeType == (type ?? S));

  // caso não seja uma List<String>: false
  bool get hasEmpty {
    try {
      if (this is! List<String>) throw Exception('Precisa ser uma lista de String');
      for (String value in this as List<String>) {
        if (value.isEmpty) return true;
      }

      return false;
    } on Exception catch (_, __) {
      log('Precisa ser uma lista de String', time: DateTime.now(), stackTrace: __);
      return false;
    }
  }

  // orElse Future
  Future<E> firstWhereFuture(bool Function(E element) test, {Future<E> Function()? orElse}) async {
    int length = this.length;
    for (int i = 0; i < length; i++) {
      E element = this[i];
      if (test(element)) return element;
      if (length != this.length) throw ConcurrentModificationError(this);
    }
    if (orElse != null) return await orElse();
    throw Exception();
  }

  List<Widget> getTabs(List<BookCategoria> categorias) {
    assert(this is List<List<Book>>);
    return List.generate(
      length,
      (index) {
        Widget tab;
        if (index <= categorias.reversed.length - 1) {
          final category = categorias.reversed.elementAt(index);
          tab = Tab(
            child: Text(
              category.name,
              style: const TextStyle(fontSize: 12),
            ),
          );
        } else {
          tab = const Tab(
            child: Text(
              'Padrão',
              style: TextStyle(fontSize: 12),
            ),
          );
        }
        return tab;
      },
    ).reversed.toList();
  }

  List<List<Book>> filterList(List<BookCategoria> categorias) {
    assert(this is List<Book>);
    final filter = List.generate(
      categorias.length + 1,
      (index) {
        if (index <= categorias.length - 1) {
          final category = categorias.reversed.elementAt(index);
          return (this as List<Book>).where((element) => category.books.contains(element.id)).toList();
        } else {
          return (this as List<Book>)
              .where(
                (book) => !categorias
                    .map((e) => e.books)
                    //
                    .any((bookIDS) => bookIDS.contains(book.id)),
              )
              .toList();
        }
      },
    ).reversed.toList();

    // filter.forEachIndexed((index, list) {
    //   if (list.isEmpty && index > 0) filter.removeAt(index);
    // });

    if (filter.first.isEmpty) filter.removeLast();

    // print('${DateTime.now().difference(now)}');
    return filter;
  }

  String encode() => json.encode(this);
}
