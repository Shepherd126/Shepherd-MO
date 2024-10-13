import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/pages/home.dart';
import 'package:shepherd_mo/providers/provider.dart';
import 'package:shepherd_mo/route/route.dart';
import 'package:shepherd_mo/theme/dark_theme.dart';
import 'package:shepherd_mo/theme/light_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Shepherd());
}

class Shepherd extends StatelessWidget {
  const Shepherd({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => UIProvider()..init(),
      child: Consumer<UIProvider>(
        builder: (context, UIProvider notifier, child) {
          return GetMaterialApp(
            title: 'Shepherd',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: notifier.themeMode,
            home: const HomePage(),
            getPages: AppRoutes.routes,
            navigatorKey: navigatorKey,
          );
        },
      ),
    );
  }
}
