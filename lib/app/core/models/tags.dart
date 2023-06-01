// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Tags {
  final String? description;
  final String title;
  Tags({
    this.description,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'description': description,
      'title': title,
    };
  }

  factory Tags.fromMap(Map<String, dynamic> map) {
    return Tags(
      description: map['description'] != null ? map['description'] as String : null,
      title: map['title'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tags.fromJson(String source) => Tags.fromMap(json.decode(source) as Map<String, dynamic>);

  Tags copyWith({
    String? description,
    String? title,
  }) {
    return Tags(
      description: description ?? this.description,
      title: title ?? this.title,
    );
  }

  @override
  bool operator ==(covariant Tags other) {
    if (identical(this, other)) return true;

    return other.description == description && other.title == title;
  }

  @override
  int get hashCode => description.hashCode ^ title.hashCode;
}
