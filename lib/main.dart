import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OtakuHub',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: const Text('OtakuHub 🎌')),
        body: const Center(
          child: Text('مرحباً بك في OtakuHub! 🚀'),
        ),
      ),
    );
  }
}
