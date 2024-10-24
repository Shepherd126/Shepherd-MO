import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shepherd_mo/controller/controller.dart';
import 'package:shepherd_mo/pages/home_page.dart';
import 'package:shepherd_mo/providers/provider.dart';
import 'package:shepherd_mo/route/route.dart';
import 'package:shepherd_mo/theme/dark_theme.dart';
import 'package:shepherd_mo/theme/light_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = Get.put(LocaleController());
  await localeController.loadPreferredLocale();
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
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('vi', 'VN'),
            ],
            locale: Get.locale,
            fallbackLocale: const Locale('en', 'US'),
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
