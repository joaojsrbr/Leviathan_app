import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:leviathan_app/app/core/constants/fonte.dart';
import 'package:leviathan_app/app/core/constants/grid.dart';
import 'package:leviathan_app/app/core/constants/home.dart';
import 'package:leviathan_app/app/core/constants/type_event.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/list_extensions.dart';
import 'package:leviathan_app/app/core/interfaces/hive_service.dart';
import 'package:leviathan_app/app/core/models/book_categoria.dart';

class HiveController extends ChangeNotifier {
  final Service _service;

  HiveController(this._service);

  // late Orders _orders;
  late Fonte _fonte;
  late ModeView _modeView;
  late HomeSelect _homeSelect;
  late List<BookCategoria> _categorias;
  late bool _chaptersReverse;
  late TypeEvent _typeEvent;

  Fonte get fonte => _fonte;

  UnmodifiableListView<BookCategoria> get categorias => UnmodifiableListView(_categorias.sorted((a, b) => a.compareTo(b)));

  UnmodifiableListView<BookCategoria> get noSortCategorias => UnmodifiableListView(_categorias);

  ModeView get modeView => _modeView;
  HomeSelect get homeSelect => _homeSelect;
  bool get chaptersReverse => _chaptersReverse;
  TypeEvent get type => _typeEvent;

  final _defaultValueFonte = Fonte.NEOX_SCANS;
  final _defaultValueModeView = ModeView.GRID_3X3;
  final _defaultValueHomeSelect = HomeSelect.Home;
  final _defaultValueCategory = '[]';
  final _defaultTypeEvent = TypeEvent.RELEASE;
  final _defaultValueChaptersReverse = true;

  Future<void> setBookCategoria(void Function(List<BookCategoria> lista) operation, [bool notify = true]) async {
    operation.call(_categorias);

    if (notify) notifyListeners();
    final encode = categorias.map((e) => e.toJson()).toList().encode();
    await _service.save('category', encode, false);
  }

  Future<void> setChaptersReverse(bool? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _chaptersReverse) return;
    _chaptersReverse = value;
    if (notify) notifyListeners();
    await _service.save('chapters_reverse', value);
  }

  Future<void> setFonte(Fonte? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _fonte) return;
    _fonte = value;
    if (notify) notifyListeners();
    await _service.save('fonte', value);
  }

  Future<void> setTypeEvent(TypeEvent? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _typeEvent) return;
    _typeEvent = value;
    if (notify) notifyListeners();
    await _service.save('type_event', value);
  }

  Future<void> setHomeSelect(HomeSelect? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _homeSelect) return;
    _homeSelect = value;
    if (notify) notifyListeners();
    await _service.save('home_select', value);
  }

  Future<void> setModeView(ModeView? value, [bool notify = true]) async {
    if (value == null) return;
    if (value == _modeView) return;
    _modeView = value;
    if (notify) notifyListeners();
    await _service.save('mode_view', value);
  }

  Future<void> loadAll() async {
    _fonte = await _service.load('fonte', _defaultValueFonte);
    _typeEvent = await _service.load('type_event', _defaultTypeEvent);

    _chaptersReverse = await _service.load('chapters_reverse', _defaultValueChaptersReverse);
    _homeSelect = await _service.load('home_select', _defaultValueHomeSelect);
    _modeView = await _service.load('mode_view', _defaultValueModeView);

    _categorias = (await _service.load('category', _defaultValueCategory, print: _bookCategoriaPrint))
        .decode<List>()
        .map((e) => BookCategoria.fromJson(e))
        .toList();
  }

  _bookCategoriaPrint(String data) {
    return data.decode<List>().map((e) => BookCategoria.fromJson(e)).toList();
  }
}

extension on String {
  T decode<T>() => json.decode(this);
}



// class HiveControllerMock extends HiveController {
//   HiveControllerMock(super._service);

//   @override
//   Fonte get fonte => Fonte.NEOX_SCANS;
//   @override
//   bool get bookCacheEnable => true;
//   @override
//   List<String> get disableOnlyBookCache => <String>[];
//   @override
//   TypeEvent get type => TypeEvent.RELEASE;
// }
