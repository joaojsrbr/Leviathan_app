import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leviathan_app/app/core/constants/app.dart';
import 'package:leviathan_app/app/core/routes/routes.dart';
import 'package:leviathan_app/app/core/themes/themes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    // final RepositoryController repositoryController = context.watch<RepositoryController>();
    // debugInvertOversizedImages = true;
    // lightTheme.colorScheme.toString();
    return MaterialApp(
      title: 'Leviathan',
      localizationsDelegates: App.localizationsDelegates,
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      routes: AppRoutes.routes,
      locale: const Locale('pt', 'BR'),
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: RouteName.HOME,
    );
  }
}
