import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  primaryColor: Colors.white,
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColorLight: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
    ),
  ),
  colorScheme: ColorScheme.light(
      background: Colors.grey[200]!,
      primary: Colors.grey[100]!,
      secondary: Colors.grey[200]!),
);
