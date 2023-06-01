import 'dart:async';

import 'package:flutter/foundation.dart';

class Debouncer {
  // void cancel() => _timer?.cancel();

  final Duration duration;
  Timer? _timer;
  Debouncer({this.duration = const Duration(milliseconds: 400)});

  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }
}
