import 'package:assets_manager/pages/home_page.dart';
import 'package:flutter/material.dart';

import 'constants/styles.dart';

void main() {
  runApp(const AssetsManagerApp());
}

class AssetsManagerApp extends StatelessWidget {
  const AssetsManagerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assets Manager',
      theme: ThemeData(
        primarySwatch: primaryBlack,
      ),
      home: HomePage(),
      showSemanticsDebugger: false,
      debugShowCheckedModeBanner: false,
    );
  }
}
