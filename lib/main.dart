import 'package:flutter/material.dart';
import 'package:skytech/screens/dashboard.dart';
import 'package:skytech/screens/select-user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff002F3F),
        primaryColor: Colors.black,
        accentColor: Colors.amber
      ),
      home: DashBoard(),
    );
  }
}

