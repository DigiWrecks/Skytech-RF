import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skytech/screens/dashboard.dart';
import 'package:skytech/screens/select-user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff4E5A5E),
        primaryColor: Color(0xff1C2B2D),
        accentColor: Color(0xff91C3E8),
        textTheme: GoogleFonts.ubuntuTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Loading(),
    );
  }
}


class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  String deviceID = 'N/A';

  getDeviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(Platform.isAndroid){
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setState(() {
        deviceID = androidInfo.androidId;
      });
    }
    else{
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      setState(() {
        deviceID = iosInfo.identifierForVendor;
      });
    }
  }

  checkAvailiability(BuildContext context) async {
    await Firebase.initializeApp();
    var sub = await FirebaseFirestore.instance.collection('user').where('deviceId', isEqualTo: deviceID).get();
    var users = sub.docs;
    if(users.isNotEmpty){
      //innawa
      var sub2 = await FirebaseFirestore.instance.collection('admin').where('code',isEqualTo: users[0]['code']).get();
      var companies = sub2.docs;
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => DashBoard(
          deviceID: deviceID,
          companyName: companies[0]['fname']+' '+companies[0]['lname'],
          id: users[0]['id'],
          name: users[0]['name'],
          code: companies[0]['code'],
          email: users[0]['email'],
          isLogged: users[0]['logged'],
          lastTime: users[0]['lastTime'],
        )),
      );
    }
    else{
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => SelectUser()),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceID();
    checkAvailiability(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


