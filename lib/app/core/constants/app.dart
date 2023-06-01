// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App {
  App._();

  static final List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static final BOOKCHAPTERCACHE = CacheManager(
    Config(
      'chapter_cache',
      stalePeriod: const Duration(minutes: 20),
      repo: JsonCacheInfoRepository(databaseName: 'book_img_cache'),
    ),
  );

  static final BOOKITEMCACHE = CacheManager(
    Config('book_item_cache', stalePeriod: const Duration(days: 1)),
  );

  /// [URL] do site da NeoxScan [SCAN].
  static const String NEOXURL = 'https://neoxscans.net';

  /// [URL] do site da MangaBTT.
  static const String MANGABTTURL = 'https://mangabtt.com';

  /// [API] da ArgosScan [SCAN].
  // static const String argosAPI = 'https://argosscan.com/graphql';

  // /// [URL] da ArgosScan [SCAN].
  // static const String argosURL = 'https://argosscan.com';

  // /// [API] da kitsu [API]
  // static const String kitsuAPI = 'https://kitsu.io';

  // /// [URL] do site da CronosScan [SCAN].
  // static const String gloriousURL = 'https://gloriousscan.com';

  // /// [URL] do site da MarkScan [SCAN].
  // static const String markURL = 'https://markscans.online';

  // /// [API] da MangaLivre [AGREGADOR].
  // static const String mangalivreAPI = 'https://mangalivre.net/home';

  // /// [URL] da MangaLivre [AGREGADOR].
  // static const String mangalivreURL = 'https://mangalivre.net';

  // /// [URL] do site da PrismaScan [SCAN].
  // static const String prismaURL = 'https://prismascans.net';

  // /// [URL] do site da RandomScan [SCAN].
  // static const String randomURL = 'https://randomscans.com';

  // /// [API] do site da ReaperScan [SCAN].
  // static const String reaperURL = 'https://api.reaperscans.net';

  // static const String reaperURLComics = 'https://reaperscans.net/_next/data/5RyTRYYfhmCKv3pSROsPd/pt/comics.json';

  // /// [URL] do site MuitoManga [AGREGADOR].
  // static const String muitoMangaURL = 'https://muitomanga.com';

  // /// [URL] do site da OlympusScan [SCAN].
  // static const String olympusURL = 'https://br.olympusscanlation.com';
}
