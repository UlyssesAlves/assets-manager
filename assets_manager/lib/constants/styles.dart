import 'package:flutter/material.dart';

const int _blackPrimaryValue = 0xFF000000;

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);

const kAssetsSearchInactiveFilterForegroundColor =
    Color.fromARGB(255, 142, 152, 163);

const kAssetsSearchInactiveFilterBackgroundColor =
    Color.fromARGB(255, 216, 223, 230);
