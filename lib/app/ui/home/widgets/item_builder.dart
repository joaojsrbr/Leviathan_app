import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/widgets/book_item.dart';

Widget itemBuilder(BuildContext context, Book book, int index) {
  return BookItem(
    book: book,
    isBiblioteca: false,
  );
}
