import 'package:get/get.dart';
import 'package:shepherd_mo/pages/home.dart';
import 'package:shepherd_mo/pages/settings.dart';

class AppRoutes {
  static const String home = '/home';
  static const String schedule = '/schedule';
  static const String notifications = '/notifications';
  static const String menu = '/menu';
  static const String settings = '/settings';

  static final List<GetPage> routes = [
    GetPage(name: home, page: () => const HomePage()),
    GetPage(name: schedule, page: () => const ScheduleTab()),
    GetPage(name: notifications, page: () => const NotificationTab()),
    GetPage(name: menu, page: () => const MenuTab()),
    GetPage(name: settings, page: () => const SettingsPage()),
  ];
}
