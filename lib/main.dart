import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skytech/screens/admin/admin-dashboard.dart';
import 'package:skytech/screens/admin/user-analytics.dart';
import 'package:skytech/screens/dashboard.dart';
import 'package:skytech/screens/log.dart';
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
        accentColor: Colors.amber,
        textTheme: GoogleFonts.ubuntuTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: SelectUser(),
    );
  }
}

