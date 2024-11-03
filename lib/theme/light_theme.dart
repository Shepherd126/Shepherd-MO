import 'package:flutter/material.dart';

// Define the primary color
const Color primaryGoldenColor = Color(0xFFEEC05C);

ThemeData lightTheme = ThemeData(
  primaryColor: Colors.white,
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColorLight: Colors.white,

  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),

  // Color Scheme
  colorScheme: ColorScheme.light(
    surface: Colors.grey[100]!,
    primary: primaryGoldenColor, // Main primary color for widgets like buttons
    secondary: Colors.grey[200]!,
    onPrimary: Colors.black, // Text color on primary surfaces
  ),

  // Text Selection Theme (TextField selection, cursor, etc.)
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: primaryGoldenColor,
    selectionColor: primaryGoldenColor.withOpacity(0.5),
    selectionHandleColor: primaryGoldenColor,
  ),

  iconTheme: const IconThemeData(color: Colors.black),
  primaryIconTheme: const IconThemeData(color: Colors.black),

  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(Colors.black), // Text color
      backgroundColor: WidgetStateProperty.all(Colors.orange),
      padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0)),
      textStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      )),
    ),
  ),

  // Input Decoration Theme (TextField styling)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[200],
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: primaryGoldenColor, width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    labelStyle: TextStyle(color: Colors.black),
    focusColor: primaryGoldenColor,
    iconColor: Colors.black,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGoldenColor,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
);
