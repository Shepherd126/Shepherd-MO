import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/api/firebase_api.dart';
import 'package:shepherd_mo/controller/controller.dart';
import 'package:shepherd_mo/firebase_options.dart';
import 'package:shepherd_mo/pages/login_page.dart';
import 'package:shepherd_mo/pages/token_check.dart';
import 'package:shepherd_mo/providers/signalr_provider.dart';
import 'package:shepherd_mo/providers/ui_provider.dart';
import 'package:shepherd_mo/route/route.dart';
import 'package:shepherd_mo/theme/dark_theme.dart';
import 'package:shepherd_mo/theme/light_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = Get.put(LocaleController());
  Get.put(AuthorizationController());
  Get.put(RefreshController());
  await localeController.loadPreferredLocale();
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
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
      isTokenExpired = JwtDecoder.isExpired(token!);
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UIProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (context) => SignalRService()..startConnection(),
        ),
      ],
      child: Consumer<UIProvider>(
        builder: (context, UIProvider notifier, child) {
          return GetMaterialApp(
            navigatorObservers: [routeObserver],
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
