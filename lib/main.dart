import 'package:flutter/material.dart';
import 'package:pebble/screens/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pebble',
      theme: ThemeData(
        primaryColor: Color(0xFFAEC6CF),
        accentColor: Color(0xFFF2F5FA),
        canvasColor: Colors.transparent,
      ),
      home: Home(),
    );
  }
}
