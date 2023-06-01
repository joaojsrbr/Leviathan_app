import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class BookCategoria implements Comparable<BookCategoria> {
  final String name;
  final List<String> books;
  final String id;
  final DateTime? updatedAt;
  final DateTime createdAt;

  const BookCategoria({
    required this.name,
    required this.books,
    required this.id,
    this.updatedAt,
    required this.createdAt,
  });

  @override
  bool operator ==(covariant BookCategoria other) {
    if (identical(this, other)) return true;
    // final listEquals = const DeepCollectionEquality().equals;

    return other.name == name && other.id == id;
  }

  String createdAtString(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final diff = DateTime.now().difference(createdAt);
    if (diff.inHours >= 12) {
      return DateFormat(DateFormat.MONTH_DAY, '${locale.languageCode}_${locale.countryCode}').format(createdAt);
    }
    return DateFormat(DateFormat.HOUR24_MINUTE, '${locale.languageCode}_${locale.countryCode}').format(createdAt);
  }

  String? updatedAtString(BuildContext context) {
    if (updatedAt == null) return null;
    final locale = Localizations.localeOf(context);
    final diff = DateTime.now().difference(updatedAt!);
    if (diff.inHours >= 12) {
      return DateFormat(DateFormat.MONTH_DAY, '${locale.languageCode}_${locale.countryCode}').format(updatedAt!);
    }
    return DateFormat(DateFormat.HOUR24_MINUTE, '${locale.languageCode}_${locale.countryCode}').format(updatedAt!);
  }

  @override
  int get hashCode => name.hashCode ^ books.hashCode ^ id.hashCode;

  BookCategoria copyWith({
    String? name,
    List<String>? books,
    String? id,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return BookCategoria(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      books: books ?? this.books,
      id: id ?? this.id,
    );
  }

  Map<dynamic, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'books': books,
      'id': id,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory BookCategoria.fromMap(Map<dynamic, dynamic> map) {
    return BookCategoria(
      name: map['name'] as String,
      books: List<String>.from(map['books']),
      id: map['id'] as String,
      updatedAt: map['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int) : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory BookCategoria.fromJson(String source) => BookCategoria.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  int compareTo(BookCategoria other) {
    if (other.books.length < books.length) return 0;
    return 1;
  }
}
