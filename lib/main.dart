// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/initialize_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '转盘抽奖',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InitializePage(),
    );
  }
}
