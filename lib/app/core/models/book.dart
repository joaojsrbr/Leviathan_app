// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/constants/fonte.dart';
import 'package:leviathan_app/app/core/models/chapter.dart';
import 'package:leviathan_app/app/core/models/tags.dart';

class Book {
  final String title;
  final String id;
  final String url;
  final String originalImage;
  final Fonte fonte;
  final String? largeImage;
  final String? mediumImage;
  final String? type;
  final String? sinopse;
  final String? status;
  final String? autor;
  final String? lastChapter;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final Color? seedColor;
  final double? score;
  final List<Tags>? tags;
  final List<Chapter>? chapters;

  final Map<String, dynamic>? data;

  const Book({
    required this.title,
    required this.id,
    required this.url,
    required this.originalImage,
    required this.fonte,
    this.largeImage,
    this.data,
    this.seedColor,
    this.mediumImage,
    this.createdAt,
    this.type,
    this.lastChapter,
    this.sinopse,
    this.status,
    this.autor,
    this.updatedAt,
    this.score,
    this.tags,
    this.chapters,
  });

  Map<dynamic, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'id': id,
        'seedColor': seedColor?.value,
        'url': url,
        'originalImage': originalImage,
        'largeImage': largeImage,
        'mediumImage': mediumImage,
        'fonte': fonte.index,
        'data': data,
        'createdAt': createdAt?.toIso8601String(),
        'type': type,
        'lastChapter': lastChapter,
        'sinopse': sinopse,
        'status': status,
        'autor': autor,
        'updatedAt': updatedAt?.toIso8601String(),
        'score': score,
        'tags': tags?.map((e) => e.toMap()).toList(),
        'chapters': chapters?.map((e) => e.toJson()).toList(),
      };

  factory Book.fromJson(Map<dynamic, dynamic> json) => Book(
        title: json['title'] as String,
        id: json['id'] as String,
        url: json['url'] as String,
        originalImage: json['originalImage'] as String,
        largeImage: json['largeImage'] as String?,
        mediumImage: json['mediumImage'] as String?,
        fonte: Fonte.values.elementAt(json['fonte'] as int),
        createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
        type: json['type'] as String?,
        lastChapter: json['lastChapter'] as String?,
        sinopse: json['sinopse'] as String?,
        status: json['status'] as String?,
        data: json['data'] != null ? Map<String, dynamic>.from((json['data'] as Map<String, dynamic>)) : null,
        autor: json['autor'] as String?,
        score: (json['score'] as num?)?.toDouble(),
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
        seedColor: json['seedColor'] != null ? Color(json['seedColor'] as int) : null,
        tags: (json['tags'] as List<dynamic>?)?.map((e) => Tags.fromMap(e)).toList(),
        chapters: (json['chapters'] as List<dynamic>?)?.map((e) => Chapter.fromJson(e)).toList(),
      );

  String get getIMG => largeImage ?? mediumImage ?? originalImage;

  bool get isNovel => (type?.toLowerCase().contains('novel') ?? false || title.toLowerCase().contains('novel'));

  @override
  int get hashCode {
    return title.hashCode ^
        id.hashCode ^
        url.hashCode ^
        data.hashCode ^
        originalImage.hashCode ^
        fonte.hashCode ^
        largeImage.hashCode ^
        mediumImage.hashCode ^
        createdAt.hashCode ^
        type.hashCode ^
        sinopse.hashCode ^
        status.hashCode ^
        autor.hashCode ^
        lastChapter.hashCode ^
        updatedAt.hashCode ^
        seedColor.hashCode ^
        score.hashCode ^
        tags.hashCode ^
        chapters.hashCode;
  }

  Book copyWith({
    String? title,
    String? id,
    String? url,
    String? originalImage,
    Fonte? fonte,
    String? largeImage,
    String? mediumImage,
    DateTime? createdAt,
    String? type,
    String? sinopse,
    String? status,
    Map<String, dynamic>? data,
    String? autor,
    String? lastChapter,
    DateTime? updatedAt,
    Color? seedColor,
    double? score,
    List<Tags>? tags,
    List<Chapter>? chapters,
  }) {
    return Book(
      title: title ?? this.title,
      data: data ?? this.data,
      id: id ?? this.id,
      url: url ?? this.url,
      originalImage: originalImage ?? this.originalImage,
      fonte: fonte ?? this.fonte,
      largeImage: largeImage ?? this.largeImage,
      mediumImage: mediumImage ?? this.mediumImage,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      sinopse: sinopse ?? this.sinopse,
      status: status ?? this.status,
      autor: autor ?? this.autor,
      lastChapter: lastChapter ?? this.lastChapter,
      updatedAt: updatedAt ?? this.updatedAt,
      seedColor: seedColor ?? this.seedColor,
      score: score ?? this.score,
      tags: tags ?? this.tags,
      chapters: chapters ?? this.chapters,
    );
  }

  @override
  bool operator ==(covariant Book other) {
    if (identical(this, other)) return true;
    final equals = const DeepCollectionEquality().equals;

    return other.title == title &&
        other.id == id &&
        other.url == url &&
        other.originalImage == originalImage &&
        other.fonte == fonte &&
        other.largeImage == largeImage &&
        other.mediumImage == mediumImage &&
        other.createdAt == createdAt &&
        other.type == type &&
        other.sinopse == sinopse &&
        other.status == status &&
        other.autor == autor &&
        other.lastChapter == lastChapter &&
        other.updatedAt == updatedAt &&
        other.seedColor == seedColor &&
        other.score == score &&
        equals(other.data, data) &&
        equals(other.tags, tags) &&
        equals(other.chapters, chapters);
  }
}
