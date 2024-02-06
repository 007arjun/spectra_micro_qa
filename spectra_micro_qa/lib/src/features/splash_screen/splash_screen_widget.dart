import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spectra_micro_qa/src/features/login_page/login_page_widget.dart';

class SplashScreenWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FutureBuilder(
          future: Future.delayed(Duration(seconds: 2)),
          builder: (context, snapshot) {
            double opacity = snapshot.connectionState == ConnectionState.done ? 1.0 : 0.0;
            Timer(
              Duration(seconds: 4),
                  () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPageWidget(),
                ),
              ),
            );

            return AnimatedOpacity(
              duration: Duration(seconds: 1),
              opacity: opacity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset('assets/spectrum.png'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}