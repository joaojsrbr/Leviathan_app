import 'package:leviathan_app/app/core/models/chapter.dart';

class IsRead {
  final Chapter chapter;
  final bool read;
  final double readPercent;
  IsRead(this.read, this.readPercent, this.chapter);

  @override
  bool operator ==(covariant IsRead other) {
    if (identical(this, other)) return true;

    return other.chapter == chapter;
  }

  @override
  int get hashCode => chapter.hashCode ^ read.hashCode ^ readPercent.hashCode;

  @override
  String toString() => 'readPercent: $readPercent';
}
