// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:leviathan_app/app/core/constants/fonte.dart';

class Chapter {
  final String id;
  final bool read;
  final Fonte fonte;
  final String url;
  final double chapterNumber;
  final String chapterName;
  final double? chapterVersion;
  final bool? chapterFix;
  final double? readPercent;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final String? chapterDescription;

  const Chapter({
    required this.id,
    this.read = false,
    required this.fonte,
    required this.url,
    required this.chapterNumber,
    this.chapterDescription,
    required this.chapterName,
    this.readPercent,
    this.chapterFix,
    this.chapterVersion,
    this.updatedAt,
    this.createdAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json['id'] as String,
        chapterVersion: json['chapterVersion'] as double?,
        chapterFix: json['chapterFix'] as bool?,
        read: json['read'] as bool? ?? false,
        fonte: Fonte.values.elementAt(json['fonte'] as int),
        url: json['url'] as String,
        chapterDescription: json['chapterDescription'] as String?,
        chapterNumber: json['chapterNumber'] as double,
        chapterName: json['chapterName'] as String,
        readPercent: (json['readPercent'] as num?)?.toDouble(),
        updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
        createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
      );

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'id': id,
        'read': read,
        'fonte': fonte.index,
        'chapterFix': chapterFix,
        'chapterVersion': chapterVersion,
        'url': url,
        'chapterName': chapterName,
        'chapterNumber': chapterNumber,
        'chapterDescription': chapterDescription,
        'readPercent': readPercent,
        'updatedAt': updatedAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
      };

  (int?, int?, int?, int?, int?) get _allTime {
    int? days;
    int? hours;
    int? minutes;
    int? seconds;
    int? years;

    if (createdAt != null) {
      final DateTime now = DateTime.now();

      final Duration duration = now.difference(createdAt!);
      days = duration.inDays;

      hours = duration.inHours;
      minutes = duration.inMinutes;
      seconds = duration.inSeconds;
      years = now.year - createdAt!.year;
    }

    return (years, days, hours, minutes, seconds);
  }

  String? get diffTime {
    final (years, days, hours, minutes, seconds) = _allTime;
    if (hours == null) return null;
    String? diffTime = '';

    if (hours >= 24) {
      if (days == null) return null;
      if (days >= 363) {
        if (years == null) return null;
        String sub = 'ano atrás';
        if (years > 1) sub = 'anos atrás';
        diffTime = 'há $years $sub';
      } else {
        diffTime = 'há $days dias atrás';
      }
    } else if (hours <= 24 && hours > 0) {
      diffTime = 'há $hours horas atrás';
    } else if ((hours) <= 0) {
      if (minutes == null) return null;
      diffTime = 'há $minutes minutos atrás';
      if (minutes > 120) {
        if (seconds == null) return null;
        diffTime = 'há $seconds segundos atrás';
      }
    } else if (minutes == 0) {
      if (seconds == null) return null;
      diffTime = 'há $seconds segundos atrás';
    }

    return diffTime;
  }

  Chapter copyWith({
    String? id,
    bool? read,
    Fonte? fonte,
    double? chapterNumber,
    String? chapterDescription,
    String? url,
    bool? chapterFix,
    double? chapterVersion,
    String? chapterName,
    double? readPercent,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return Chapter(
      chapterNumber: chapterNumber ?? this.chapterNumber,
      chapterFix: chapterFix ?? this.chapterFix,
      chapterVersion: chapterVersion ?? this.chapterVersion,
      chapterDescription: chapterDescription ?? this.chapterDescription,
      id: id ?? this.id,
      read: read ?? this.read,
      fonte: fonte ?? this.fonte,
      url: url ?? this.url,
      chapterName: chapterName ?? this.chapterName,
      readPercent: readPercent ?? this.readPercent,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(covariant Chapter other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.read == read &&
        other.fonte == fonte &&
        other.chapterDescription == chapterDescription &&
        other.chapterNumber == chapterNumber &&
        other.url == url &&
        other.chapterName == chapterName &&
        other.readPercent == readPercent &&
        other.updatedAt == updatedAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        read.hashCode ^
        fonte.hashCode ^
        chapterNumber.hashCode ^
        chapterDescription.hashCode ^
        url.hashCode ^
        chapterName.hashCode ^
        readPercent.hashCode ^
        updatedAt.hashCode ^
        createdAt.hashCode;
  }
}
