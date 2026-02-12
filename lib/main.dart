import 'package:flutter/material.dart';
import 'package:zy_excel/screens/home_screen.dart';
import 'package:zy_excel/utils/screen_size.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: LayoutBuilder(
        builder: (context, constraints) {
          getInitialScreenSize(context: context);
          return HomeScreen();
        },
      ),
    );
  }
}
