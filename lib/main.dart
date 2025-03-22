import 'package:flutter/material.dart';
import 'package:kisan/landingpage.dart';

void main() {
  runApp(first());
}

class first extends StatelessWidget {
  const first({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LandingPage(),
      ),
    );
  }
}
