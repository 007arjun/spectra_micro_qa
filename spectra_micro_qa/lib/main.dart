import 'package:flutter/material.dart';
import 'package:spectra_micro_qa/src/features/splash_screen/splash_screen_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreenWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}