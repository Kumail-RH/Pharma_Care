import 'package:flutter/material.dart';

class AppTheme {
  // Common Colors
  static const Color primaryColor = Color(0xFF05696B);
  static const Color transparentColor = Color(0x00000000);
  static const Color blackColor = Color(0xFF000000);
  static const Color whiteColor = Color(0xFFFFFFFF);

  // Light Theme Colors
  static const Color lightBgColor = Color(0xFFEAF7F7);
  static const Color lightFieldsBgColor = Color(0xFFF4FBFB);
  static const Color lightTextColorDark = Color(0xFF333333);
  static const Color lightTextColorLight = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color darkBgColor =
      Color(0xFF012626); // Darker version of bgColor
  static const Color darkPrimaryColor =
      Color(0xFF034245); // Darker primaryColor
  static const Color darkInputFieldColor =
      Color(0xFF4E3B31); // Muted brown for inputs
  static const Color darkFieldsBgColor = Color(0xFF1A2B2B); // Dark teal-grey
  static const Color darkTextColorDark = Color(0xFFE0E0E0); // Soft light grey
  static const Color darkTextColorLight = Color(0xFFF5F5F5); // Soft white

  // Font Family
  static const String fontFamily = "Montserrat";

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBgColor,
    fontFamily: fontFamily,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: lightFieldsBgColor,
      border: OutlineInputBorder(),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: lightTextColorDark),
      bodyMedium: TextStyle(fontSize: 14, color: lightTextColorDark),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBgColor,
    fontFamily: fontFamily,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: darkInputFieldColor,
      border: OutlineInputBorder(),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: darkTextColorDark),
      bodyMedium: TextStyle(fontSize: 14, color: darkTextColorLight),
    ),
  );
}
