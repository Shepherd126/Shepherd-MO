import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}

class LocaleController extends GetxController {
  static const String _localeKey = 'selectedLocale';

  final _currentLocale = const Locale('en', 'US').obs;

  Locale get currentLocale => _currentLocale.value;

  Future<void> loadPreferredLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString(_localeKey);

    if (languageCode == 'system') {
      // Use system locale
      var systemLocale = Get.deviceLocale;
      if (systemLocale != null &&
          (systemLocale.languageCode == 'vi' ||
              systemLocale.languageCode == 'en')) {
        // If system locale is either Vietnamese or English, use it
        _currentLocale.value = systemLocale;
      } else {
        // Default to English if system locale is unsupported
        _currentLocale.value = const Locale('en', 'US');
      }
    } else if (languageCode != null) {
      // Use the saved preference (either 'vi' or 'en')
      _currentLocale.value = Locale(languageCode);
    } else {
      // No preference saved, use system locale or default to English
      var systemLocale = Get.deviceLocale;
      if (systemLocale != null &&
          (systemLocale.languageCode == 'vi' ||
              systemLocale.languageCode == 'en')) {
        _currentLocale.value = systemLocale;
      } else {
        _currentLocale.value = const Locale('en', 'US');
      }
    }

    // Update the app locale
    Get.updateLocale(_currentLocale.value);
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();

    if (languageCode == 'system') {
      await prefs.setString(_localeKey, 'system');
      _currentLocale.value = Get.deviceLocale ?? const Locale('en', 'US');
    } else {
      await prefs.setString(_localeKey, languageCode);
      _currentLocale.value = Locale(languageCode);
    }

    Get.updateLocale(_currentLocale.value);
    print(Get.locale);
    print(_currentLocale.value);
  }

  Map<CalendarFormat, String> get availableCalendarFormats {
    if (currentLocale.languageCode == 'vi') {
      return {
        CalendarFormat.month: 'Tháng',
        CalendarFormat.twoWeeks: '2 Tuần',
        CalendarFormat.week: 'Tuần',
      };
    } else {
      return {
        CalendarFormat.month: 'Month',
        CalendarFormat.twoWeeks: '2 Weeks',
        CalendarFormat.week: 'Week',
      };
    }
  }
}

class AuthorizationController extends GetxController {
  var isAuthorized = false.obs;
  var isLeader = false.obs;

  // Method to update authorization status
  void updateAuthorizationStatus(bool newStatus) {
    isAuthorized.value = newStatus;
  }

  void updateGroupAuthorizationStatus(bool newStatus) {
    isLeader.value = newStatus;
  }
}

class TaskController extends GetxController {
  var shouldRefresh = false.obs;

  void setShouldRefresh(bool value) {
    shouldRefresh.value = value;
  }
}
