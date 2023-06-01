import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leviathan_app/app/core/database/library_database.dart';
import 'package:leviathan_app/app/core/interfaces/hive_service.dart';
import 'package:leviathan_app/app/core/repositories/library_repository.dart';
import 'package:leviathan_app/app/core/repositories/load_book_repository.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:leviathan_app/app/core/services/hive/hive_service.dart';
import 'package:leviathan_app/app/core/utils/is_selected.dart';
import 'package:leviathan_app/app/my_app.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  // runZonedGuarded(() => null, (error, stack) { })
  WidgetsFlutterBinding.ensureInitialized();

  final HiveServiceImpl serviceHive = HiveServiceImpl('book', start: _startDependencies);

  await Future.wait([
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]),
    SystemChrome.setPreferredOrientations(DeviceOrientation.values),
    serviceHive.init(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  await analytics.setAnalyticsCollectionEnabled(true);

  final hiveController = serviceHive.getDependencies<HiveController>();

  final bookDatabase = serviceHive.getDependencies<LibraryDatabaseImpl>();

  final providers = [
    ChangeNotifierProvider(create: (context) => IsSelected()),
    ChangeNotifierProvider<LibraryRepository>(create: (context) => LibraryRepository(bookDatabase)),
    ChangeNotifierProvider<HiveController>(create: (context) => hiveController),
    ChangeNotifierProvider<LoadBookRepository>(create: (context) => LoadBookRepository(context.read())),
  ];

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

Future<List<dynamic>> _startDependencies(Service service) async {
  final HiveController hiveController = HiveController(service);
  final LibraryDatabaseImpl bookDatabase = LibraryDatabaseImpl(service);
  await bookDatabase.getAll();
  await hiveController.loadAll();

  return [hiveController, bookDatabase];
}


// Package: flutter_displaymode
// import 'package:flutter_displaymode/flutter_displaymode.dart';


// Future<void> _setRefreshRate() async {
//   try {
//     final modes = await FlutterDisplayMode.supported;
//     final refreshRates = modes.map((e) => e.refreshRate.toInt()).toList();

//     if (refreshRates.contains(90)) {
//       final indexOf = refreshRates.indexOf(90);
//       await FlutterDisplayMode.setPreferredMode(modes[indexOf]);
//     } else if (refreshRates.contains(60)) {
//       final indexOf = refreshRates.indexOf(60);
//       await FlutterDisplayMode.setPreferredMode(modes[indexOf]);
//     } else {
//       await FlutterDisplayMode.setHighRefreshRate();
//     }
//   } on PlatformException catch (_, __) {}
// }
