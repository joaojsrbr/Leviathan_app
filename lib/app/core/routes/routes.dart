// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/ui/category/view/category_view.dart';
import 'package:leviathan_app/app/ui/config/view/config.dart';
import 'package:leviathan_app/app/ui/home/view/home_view.dart';
import 'package:leviathan_app/app/ui/info/view/info_view.dart';
import 'package:leviathan_app/app/ui/read/view/read.dart';
import 'package:leviathan_app/app/ui/test_widget/view/test_view.dart';
import 'package:leviathan_app/app/ui/webview/view/webview_view.dart';

class RouteName {
  RouteName._();
  static const HOME = '/home';
  static const BOOKINFO = '/book_info';
  static const CONFIG = '/config';
  static const READ = '/read';
  static const WEBVIEW = '/web_view';
  static const CATEGORY = '/category';
  static const TEST = '/test';
}

class AppRoutes {
  AppRoutes._();
  static final Map<String, Widget Function(BuildContext)> routes = <String, WidgetBuilder>{
    RouteName.HOME: (context) => const HomePage(),
    RouteName.BOOKINFO: (context) => const BookInfoPage(),
    RouteName.CONFIG: (context) => const ConfigPage(),
    RouteName.READ: (context) => const BookRead(),
    RouteName.WEBVIEW: (context) => const WebViewPage(),
    RouteName.CATEGORY: (context) => const CategoryPage(),
    if (kDebugMode) RouteName.TEST: (context) => const TestWidget(),
  };
}
