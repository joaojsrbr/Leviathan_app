import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:leviathan_app/app/core/constants/fonte.dart';
import 'package:leviathan_app/app/core/constants/type_event.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/list_extensions.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/string_extensions.dart';
import 'package:leviathan_app/app/core/interfaces/success.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/models/chapter.dart';
import 'package:leviathan_app/app/core/models/tags.dart';
import 'package:leviathan_app/app/core/services/custom_dio.dart';
import 'package:leviathan_app/app/core/utils/object_parse.dart';
import 'package:leviathan_app/app/core/utils/parse_datetime.dart';
import 'package:leviathan_app/app/core/utils/scraping.util.dart';
import 'package:loading_more_list/loading_more_list.dart';

part 'manga_btt/manga_btt_repository.dart';
part 'neox/neox_repository.dart';

abstract class ILoadBook extends LoadingMoreBase<Book> {
  int index = 0;
  bool isSuccess = false;
  // ignore: prefer_final_fields
  bool _hasMore = true;
  bool forceRefresh = false;

  factory ILoadBook.neox() => _NeoxRepository._instance;

  factory ILoadBook.mangabtt() => _MangaBTTRepository._instance;

  final CustomDio _customDio = CustomDio();

  TypeEvent _type = TypeEvent.RELEASE;

  TypeEvent get type => _type;

  set setType(TypeEvent event) => _type = event;

  final int initialIndex;

  ILoadBook({required this.index, required this.initialIndex});

  String get baseURL => fonte.baseURL;

  Fonte get fonte;

  Future<Result<Book>> bookInfo(Book book);

  Future<Result<List<String>>> getContent(Chapter chapter);

  Future<String> getURLByTitle(String title);

  Future<Book> getBookByURL(String title);

  // ignore: unused_element
  Map<String, String> get _headers => {};

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    index = initialIndex;
    isSuccess = false;
    _hasMore = false;
    forceRefresh = notifyStateChanged;
    bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
    // if (notifyStateChanged) {
    //   forceRefresh = true;
    //   result = await super.refresh( notifyStateChanged);
    // } else {
    //   forceRefresh = false;
    //   result = await super.refresh( notifyStateChanged);
    // }
    // forceRefresh = false;
    // return Future.value(result);
  }

  @override
  bool get hasMore => _hasMore || forceRefresh;
}
