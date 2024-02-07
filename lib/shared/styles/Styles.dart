import 'package:chat_ai/shared/styles/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  fontFamily: 'Varela',
  colorScheme: ColorScheme.light(
    primary: lightPrimary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,

    elevation: 0,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    // titleTextStyle: TextStyle(
    //   color: Colors.black,
    //   fontSize: 20,
    //   fontFamily: 'Varela',
    //   fontWeight: FontWeight.bold,
    // ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: HexColor('121a21'),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  fontFamily: 'Varela',
  colorScheme: ColorScheme.dark(
    primary: darkPrimary,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: HexColor('121a21'),
    // foregroundColor: Colors.white,
    elevation: 0,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: HexColor('121a21'),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: HexColor('121a21'),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  ),
);