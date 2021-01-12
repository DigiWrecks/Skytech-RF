import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skytech/screens/admin/admin-dashboard.dart';
import 'package:skytech/screens/dashboard.dart';
import 'package:skytech/screens/select-user.dart';
import 'package:skytech/screens/update.dart';

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

  initOneSignal() async {

    await DotEnv().load('.env');

    OneSignal.shared.init(
        DotEnv().env['ONESIGNAL_APP_ID'],
        iOSSettings: {
          OSiOSSettings.autoPrompt: true,
          OSiOSSettings.inAppLaunchUrl: false
        }
    );
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
  }

  checkAvailiability(BuildContext context) async {
    await Firebase.initializeApp();
    var sub = await FirebaseFirestore.instance.collection('user').where('deviceId', isEqualTo: deviceID).get();
    var users = sub.docs;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminEmail = prefs.getString('adminEmail');
    
    if(users.isNotEmpty){
      //innawa
      var sub2 = await FirebaseFirestore.instance.collection('admin').where('code',isEqualTo: users[0]['code']).get();
      var companies = sub2.docs;
      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => DashBoard(
            deviceID: deviceID,
            companyName: companies[0]['fname']+' '+companies[0]['lname'],
            id: users[0]['id'],
            name: users[0]['fname']+' '+users[0]['lname'],
            code: companies[0]['code'],
            companyEmail: companies[0]['email'],
            email: users[0]['email'],
            isLogged: users[0]['logged'],
            lastTime: users[0]['lastTime'],
          )), (Route<dynamic> route) => false);
    }
    else if(adminEmail!=null){
      
      var sub = await FirebaseFirestore.instance.collection('admin').where('email', isEqualTo: adminEmail).get();
      var admin = sub.docs;
      if(admin.isNotEmpty){
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) => AdminDashboard(
              email: adminEmail,
              code: admin[0]['code'],
              fname: admin[0]['fname'],
              lname: admin[0]['lname'],
            )), (Route<dynamic> route) => false);
      }
      else{
        prefs.setString('adminEmail', null);
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) => SelectUser()), (Route<dynamic> route) => false);
      }
    }
    else{
      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => SelectUser()), (Route<dynamic> route) => false);
    }
  }

  getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String buildNumber = packageInfo.buildNumber;
    String version = packageInfo.version;
    await Firebase.initializeApp();
    var sub = await FirebaseFirestore.instance.collection('info').where('key', isEqualTo: 'buildNumber').get();
    var info = sub.docs;
    print("Version is:" + version);
    if (info.isNotEmpty) {
      if (Platform.isAndroid) {
        if (int.parse(buildNumber) < info[0]['androidBuildNumber']) {
          Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) => UpdateScreen()), (Route<dynamic> route) => false);
        }
        else{
          checkAvailiability(context);
        }
      } else {
        if (int.parse(version) < info[0]['iosBuildNumber']) {
          Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) => UpdateScreen()), (Route<dynamic> route) => false);
        }
        else{
          checkAvailiability(context);
        }
      }
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceID();
    initOneSignal();
    getPackageInfo();
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


