import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shepherd_mo/models/user.dart';

Future<User?> getLoginInfoFromPrefs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final loginInfoJson = prefs.getString('loginInfo');
  if (loginInfoJson != null) {
    final loginInfo = User.fromJson(jsonDecode(loginInfoJson));
    return loginInfo;
  }
  return null;
}
