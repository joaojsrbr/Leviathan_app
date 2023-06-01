import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:leviathan_app/app/core/constants/fonte.dart';
import 'package:leviathan_app/app/core/constants/grid.dart';
import 'package:leviathan_app/app/core/constants/home.dart';
import 'package:leviathan_app/app/core/constants/type_event.dart';
import 'package:leviathan_app/app/core/interfaces/hive_service.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:path_provider/path_provider.dart';

part 'hive_adapters.dart';

class HiveServiceImpl implements Service {
  final Future<List> Function(Service service) start;
  HiveServiceImpl(this._boxName, {required this.start});

  List<dynamic> _dependencies = [];

  D getDependencies<D>() {
    final _ = _dependencies.firstWhere((element) => element is D);
    _dependencies.removeWhere((element) => element is D);
    return _;
  }

  late final Box<dynamic> _hiveBox;

  final String _boxName;

  @override
  Future<void> init() async {
    _hiveAdapters();

    final docsDir = await getApplicationDocumentsDirectory();

    Hive.init(docsDir.path);

    await Hive.openBox<dynamic>(_boxName);

    _hiveBox = Hive.box<dynamic>(_boxName);

    _dependencies = await start.call(this);
  }

  @override
  Future<T> load<T>(String key, T defaultValue, {dynamic Function(T data)? print, bool debug = true}) async {
    try {
      final T loaded = _hiveBox.get(key, defaultValue: defaultValue) as T;
      final loadedPrint = print?.call(loaded) ?? loaded;
      // print?.call(_hiveBox.get(key, defaultValue: defaultValue) as T) ??

      if (debug) log('Hive type : $key as ${loadedPrint.runtimeType}\nHive loaded : $key as $loadedPrint with ${loadedPrint.runtimeType}');

      return Future.value(loaded);
    } catch (_, __) {
      final defaultV = print?.call(defaultValue) ?? defaultValue;
      if (debug) log('Hive type : $key as ${defaultV.runtimeType}\nHive loaded : $key as $defaultV with ${defaultV.runtimeType}');

      return Future.value(defaultValue);
    }
  }

  @override
  Future<void> save<T>(String key, T value, [bool logDebug = true]) async {
    try {
      await _hiveBox.put(key, value);
      if (logDebug) log('Hive save_type : $key as ${value.runtimeType}\nHive save : $key as $value with ${value.runtimeType}');
    } on HiveError catch (_, __) {
      if (logDebug) log('HiveError : $_\nStackTrace: $__,');
    }
  }

  void _hiveAdapters() {
    Hive.registerAdapter(_FonteAdapter());
    Hive.registerAdapter(_TypeEventAdapter());
    Hive.registerAdapter(_HomeSelectAdapter());
    Hive.registerAdapter(_BookAdapter());
    Hive.registerAdapter(_ModeViewAdapter());
  }
}
