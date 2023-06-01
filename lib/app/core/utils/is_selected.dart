import 'package:flutter/material.dart';

class IsSelected extends ValueNotifier<List<String>> {
  IsSelected() : super([]);

  String? cache;

  void add(String id) {
    if (!value.contains(id)) {
      value.add(id);
      cache = value.first;
    } else {
      value.remove(id);
    }
    notifyListeners();
  }

  void clear([bool nullCache = false]) {
    value.clear();
    if (nullCache) cache = null;
    notifyListeners();
  }

  bool get isEmpty => value.isEmpty;

  bool get isNotEmpty => value.isNotEmpty;

  bool contains(String id) => value.contains(id);

  void addAll(List<String> ids, [bool remove = false]) {
    for (final id in ids) {
      if (!value.contains(id)) {
        value.add(id);
      } else {
        if (remove) value.remove(id);
      }
    }
    notifyListeners();
  }
}
