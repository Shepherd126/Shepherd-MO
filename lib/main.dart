import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/controller/controller.dart';
import 'package:shepherd_mo/pages/event_detail.dart';
import 'package:shepherd_mo/pages/home_page.dart';
import 'package:shepherd_mo/pages/login_page.dart';
import 'package:shepherd_mo/pages/token_check.dart';
import 'package:shepherd_mo/providers/provider.dart';
import 'package:shepherd_mo/route/route.dart';
import 'package:shepherd_mo/theme/dark_theme.dart';
import 'package:shepherd_mo/theme/light_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shepherd_mo/utils/toast.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = Get.put(LocaleController());
  await localeController.loadPreferredLocale();
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  await dotenv.load();
  runApp(Shepherd(token: token));
}

class Shepherd extends StatelessWidget {
  final token; // Specify type explicitly
  const Shepherd({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    bool isTokenExpired = true;

    // Check token expiration
    if (token != null) {
      isTokenExpired = !JwtDecoder.isExpired(token!);
    }
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
            home: token == null
                ? const LoginPage()
                : TokenCheckPage(isTokenExpired: isTokenExpired),
            getPages: AppRoutes.routes,
            navigatorKey: navigatorKey,
          );
        },
      ),
    );
  }
}
