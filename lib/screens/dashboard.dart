import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:skytech/screens/log.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/toast.dart';


class DashBoard extends StatefulWidget {

  final String name;
  final String id;
  final String companyName;
  final String deviceID;
  final String code;
  final String email;
  final bool isLogged;
  final String lastTime;
  final String companyEmail;


  const DashBoard({Key key, this.name, this.id, this.companyName, this.deviceID, this.code, this.email, this.isLogged=true, this.lastTime, this.companyEmail}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String lat = "0";
  String long = "0";
  String date = "N/A";
  String location = "Fetching";
  bool logged;
  bool isForeman;
  String lastTime;
  double distance;

  int totalMins;

  getLocation() async {
    getDate();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() {
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });
  }

  getDate() async {
    DateTime now = await NTP.now();
    setState(() {
      date = DateFormat('MM/dd/yyyy').format(now.toUtc().subtract(Duration(hours: 7)));
    });
  }

  getWorkingSites() async {
    getLocation();
    var sub = await FirebaseFirestore.instance.collection('admin').doc(widget.companyEmail).collection('sites').get();
    var workingSites = sub.docs;
    for(int i=0;i<workingSites.length;i++){
      double latOfSite = workingSites[i]['lat'];
      double longOfSite = workingSites[i]['long'];
      double distance = Geolocator.distanceBetween(latOfSite, longOfSite, double.parse(lat), double.parse(long));
      print(distance);
      if(distance < 100){
        setState(() {
          location = workingSites[i]['site'];
          totalMins = workingSites[i]['total'];
        });
        break;
      }
      else{
        setState(() {
          location = null;
        });
      }
    }
  }

  calculateDistance({double sLat,double sLong}) async {
    getLocation();
    print(sLat.toString()+" "+sLong.toString());
    distance = Geolocator.distanceBetween(sLat, sLong, double.parse(lat), double.parse(long));
  }

  onLoginPressed({bool overtime=false}) async {
    print('entering login');
    ToastBar(color: Colors.orange,text: 'Please wait...').show();
    try{
      DateTime now = await NTP.now();
      String time = DateFormat('hh:mm a').format(now.toUtc().subtract(Duration(hours: 7)));
      String timestamp = now.toUtc().subtract(Duration(hours: 7)).toString();

      String playerID;
      OneSignal.shared.getPermissionSubscriptionState().then((result) {
        playerID = result.subscriptionStatus.userId;
      });


      var sub = await FirebaseFirestore.instance.collection('user').where('email',isEqualTo: widget.email).get();
      var details = sub.docs;

      List locationList = details[0]['locations'];
      if(!locationList.contains(location)){
        locationList.add(location);
      }
      print("times "+timestamp.toString());
      await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(timestamp).set({
            'timestamp': timestamp,
            'loginLat': lat,
            'logoutLat': '0',
            'loginLong': long,
            'logoutLong': '0',
            'location': location,
            'date': date,
            'overtime': overtime,
            'login': time,
            'logout': 'n/a',
            'worked': 'n/a',
            'notes': '',
            'playerId': playerID,
            'popUp': false

      }).then((value){
         FirebaseFirestore.instance.collection('user').doc(widget.email).update({
          'logged': true,
          'timestamp': timestamp,
          'locations': locationList
        }).then((value){
           setState(() {
             logged = true;
           });
           ToastBar(color: Colors.green,text: 'Logged in!').show();
         });
      });
    }
    catch(e){
      ToastBar(color: Colors.red,text: 'Something went wrong!').show();
    }
  }

  onLogoutPressed(String note) async {
    ToastBar(color: Colors.orange,text: 'Please wait...').show();

    try{

      var sub = await FirebaseFirestore.instance.collection('user').where('email',isEqualTo: widget.email).get();
      var details = sub.docs;

      String timestamp = details[0]['timestamp'];

      var sub2 = await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').where('timestamp', isEqualTo: timestamp).get();
      var locations = sub2.docs;
      calculateDistance(sLat: double.parse(locations[0]['loginLat']),sLong: double.parse(locations[0]['loginLong']));
     print('distance is'+distance.toString());

     if(distance<76){
       DateTime now = await NTP.now();
       String time = DateFormat('hh:mm a').format(now.toUtc().subtract(Duration(hours: 7)));
       var durInMins =  now.toUtc().subtract(Duration(hours: 7)).difference(DateTime.parse(timestamp)).inMinutes;
       var durInHours =  now.toUtc().subtract(Duration(hours: 7)).difference(DateTime.parse(timestamp)).inHours;
       int mins = durInMins - durInHours*60;
       // print(durInHours.toString()+" h "+mins.toString()+" min");
        totalMins += durInMins;


       await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(timestamp).update({
         'logout': time,
         'logoutLat': lat,
         'logoutLong': long,
         'notes': note,
         'worked': durInHours.toString()+" h "+mins.toString()+" min"
       });

       await FirebaseFirestore.instance.collection('user').doc(widget.email).update({
         'logged': false,
         'lastTime': durInHours.toString()+" h "+mins.toString()+" min"
       });

       await FirebaseFirestore.instance.collection('admin').doc(widget.companyEmail).collection('sites').doc(location).update({
         'total': totalMins,
       });

       setState(() {
         logged = false;
         lastTime = durInHours.toString()+" h "+mins.toString()+" min";
       });
       ToastBar(color: Colors.green,text: 'Logged out!').show();
       if(isForeman){
         Navigator.pop(context);
       }

     }
     else{
       ToastBar(color: Colors.red,text: 'You must within the range of 250ft from your logged in location!').show();
     }

    }
    catch(e){
      ToastBar(color: Colors.red,text: e.toString()).show();
    }
  }

  notePopUp(BuildContext context) async {
    TextEditingController note = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: CustomText(text: 'Note',align: TextAlign.center,color: Colors.black,),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: 'Type your note here',
                    enabledBorder:UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 5),
                    ),
                  ),
                  controller: note,
                ),
                Padding(
                  padding:  EdgeInsets.all(ScreenUtil().setHeight(40)),
                  child: Button(text: 'Submit',color: Colors.green,onclick: () async {
                    if(note.text.isNotEmpty){
                      onLogoutPressed(note.text);
                    }
                    else{
                      ToastBar(text: 'Please fill the note',color: Colors.red).show();
                    }
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  notificationLogOut({String timestamp, String locationF}) async {
    DateTime now = await NTP.now();
    String time = DateFormat('hh:mm a').format(now.toUtc().subtract(Duration(hours: 7)));
    var durInMins =  now.toUtc().subtract(Duration(hours: 7)).difference(DateTime.parse(timestamp)).inMinutes;
    var durInHours =  now.toUtc().subtract(Duration(hours: 7)).difference(DateTime.parse(timestamp)).inHours;
    int mins = durInMins - durInHours*60;
    // print(durInHours.toString()+" h "+mins.toString()+" min");

    var s = await FirebaseFirestore.instance.collection('admin').doc(widget.companyEmail).collection('sites').where('site', isEqualTo: locationF).limit(1).get();
    var locs = s.docs;

    int tot = locs[0]['total'];
    tot += durInMins;


    await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(timestamp).update({
      'logout': time,
      'logoutLat': lat,
      'logoutLong': long,
      'notes': '',
      'worked': durInHours.toString()+" h "+mins.toString()+" min"
    });

    await FirebaseFirestore.instance.collection('user').doc(widget.email).update({
      'logged': false,
      'lastTime': durInHours.toString()+" h "+mins.toString()+" min"
    });

    await FirebaseFirestore.instance.collection('admin').doc(widget.companyEmail).collection('sites').doc(locationF).update({
      'total': tot,
    });

    setState(() {
      logged = false;
      lastTime = durInHours.toString()+" h "+mins.toString()+" min";
    });
  }


  notificationPopUp(String locationF) async {
    var sub = await FirebaseFirestore.instance.collection('user').where('email',isEqualTo: widget.email).get();
    var details = sub.docs;

    String timestamp = details[0]['timestamp'];
    await getWorkingSites();
    print('before if');
    if(location!=locationF) {
      notificationLogOut(timestamp: timestamp,locationF: locationF);
      ToastBar(color: Colors.green,text: 'Logged out!').show();
    }

    ///showPopUp
    else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            title: CustomText(text: 'Do you want to stay logged in?',align: TextAlign.center,color: Colors.black,),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:  EdgeInsets.all(ScreenUtil().setHeight(40)),
                    child: Button(text: 'Yes',color: Colors.green,onclick: () async {
                      ProgressDialog pr = ProgressDialog(context);
                      pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
                      pr.style(
                          message: 'Please wait...',
                          borderRadius: 10.0,
                          backgroundColor: Colors.white,
                          progressWidget: Center(child: CircularProgressIndicator()),
                          elevation: 10.0,
                          insetAnimCurve: Curves.easeInOut,
                          messageTextStyle: TextStyle(
                              color: Colors.black, fontSize: ScreenUtil().setSp(35), fontWeight: FontWeight.bold)
                      );
                      pr.show();


                      await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(timestamp).update({
                        'popUp': true
                      });


                      ///logOUt
                      await notificationLogOut(locationF: locationF,timestamp: timestamp);
                      pr.hide();
                      pr.show();
                      await onLoginPressed(overtime: true);
                      pr.hide();
                      ///login
                      // Timer(Duration(seconds: 5),()=>onLoginPressed(overtime: true));


                      Navigator.pop(context);
                    }),
                  ),
                  Padding(
                    padding:  EdgeInsets.all(ScreenUtil().setHeight(40)),
                    child: Button(text: 'No',color: Colors.red,onclick: (){
                      Navigator.pop(context);
                      isForeman?notePopUp(context):onLogoutPressed('n/a');
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }


  StreamSubscription<QuerySnapshot> subscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDate();
    getLocation();
    getWorkingSites();
    logged = widget.isLogged;
    lastTime = widget.lastTime;
    subscription = FirebaseFirestore.instance.collection('user').where('email', isEqualTo: widget.email).snapshots().listen((datasnapshot){
      setState(() {
        var logs = datasnapshot.docs;
        logged = logs[0]['logged'];
        lastTime = logs[0]['lastTime'];
        isForeman = logs[0]['isForeman'];
      });
    });
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print('getting notification');
      Map data = result.notification.payload.additionalData;
      print(data);
      if(data['popUp']==true){
        Timer(Duration(seconds: 3),()=>notificationPopUp(data['location']));
      }
    });
    print(widget.name+widget.id+widget.code+widget.email+widget.companyName+widget.deviceID+widget.lastTime+widget.isLogged.toString());

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.assessment_sharp), onPressed: (){
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => Log(email: widget.email,)),
            );
          })
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ScreenUtil().setHeight(30),),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: ScreenUtil().setHeight(80),
                width: ScreenUtil().setWidth(260),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(10))
                ),
                child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.calendar_today,size: 20,),
                        SizedBox(width: ScreenUtil().setWidth(20),),
                        CustomText(text: date,size: ScreenUtil().setSp(30),color: Colors.black,),
                      ],
                    )
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(10),),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
              child: CustomText(text: widget.name,size: ScreenUtil().setSp(50),align: TextAlign.start,),
            ),
            SizedBox(height: ScreenUtil().setHeight(10),),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
              child: CustomText(text: 'ID : ${widget.id}',size: ScreenUtil().setSp(30),),
            ),
            SizedBox(height: ScreenUtil().setHeight(30),),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color(0xff99A8B2),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                  child: Column(
                    children: [
                      CustomText(text: 'Latitude',color: Colors.black,size: ScreenUtil().setSp(30),),
                      SizedBox(height: ScreenUtil().setHeight(15),),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                            child: CustomText(text: (double.parse(lat)).toStringAsFixed(5),color: Colors.black,size: ScreenUtil().setSp(28),),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15),),
                      CustomText(text: 'Longitude',color: Colors.black,size: ScreenUtil().setSp(30),),
                      SizedBox(height: ScreenUtil().setHeight(15),),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                            child: CustomText(text: (double.parse(long)).toStringAsFixed(5),color: Colors.black,size: ScreenUtil().setSp(28),),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15),),
                      CustomText(text: 'Company Name',color: Colors.black,size: ScreenUtil().setSp(30),),
                      SizedBox(height: ScreenUtil().setHeight(15),),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                            child: CustomText(text: widget.companyName,color: Colors.black,size: ScreenUtil().setSp(28),),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15),),
                      CustomText(text: 'Device ID',color: Colors.black,size: ScreenUtil().setSp(30),),
                      SizedBox(height: ScreenUtil().setHeight(15),),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                            child: CustomText(text: widget.deviceID,color: Colors.black,size: ScreenUtil().setSp(28),),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15),),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: ScreenUtil().setHeight(30),),

            Visibility(
              visible: !logged,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xff99A8B2),
                      border: Border.all(color: Colors.white,width: 3)
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                      child: Row(
                        children: [
                          SizedBox(width: ScreenUtil().setWidth(20)),
                          Expanded(
                            child: SizedBox(
                                child: CustomText(text: location!=null?location:'You are not within the work site!',size: ScreenUtil().setSp(35),)),
                          ),
                          IconButton(
                            onPressed: (){
                              setState(() {
                                location = "Fetching";
                              });
                              getWorkingSites();
                            },
                            icon: Icon(Icons.refresh),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(40),),
            Center(
              child: GestureDetector(
                onTap: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        content: CustomText(text: 'Are you sure you want to ${!logged?'log in':'log out'}?',color: Colors.black,),
                        actions: [
                          FlatButton(onPressed: () async {
                            ToastBar(text: 'Please wait...', color: Colors.orange).show();
                            bool isLocationServiceEnabled  = await Geolocator.isLocationServiceEnabled();
                            if(isLocationServiceEnabled){
                              LocationPermission permission = await Geolocator.checkPermission();
                             // print(permission);
                              if(permission==LocationPermission.deniedForever){
                                ToastBar(text: 'Please accept location permissions for continue', color: Colors.red).show();
                                await Geolocator.openAppSettings();
                              }
                              else if(permission == LocationPermission.denied){
                                ToastBar(text: 'Please accept location permissions for continue', color: Colors.red).show();
                                LocationPermission perm = await Geolocator.requestPermission();
                                if(perm==LocationPermission.deniedForever){
                                  ToastBar(text: 'Please accept location permissions for continue', color: Colors.red).show();
                                  await Geolocator.openAppSettings();
                                }
                              }
                              else{
                                await getWorkingSites();
                                if(location!=null||location!='Fetching'){
                                  if(!logged){
                                    onLoginPressed();
                                    Navigator.pop(context);
                                  }else{
                                    Navigator.pop(context);
                                    isForeman?notePopUp(context):onLogoutPressed('n/a');
                                  }
                                }
                                else{
                                  ToastBar(text: 'You are not within the work site!', color: Colors.red).show();
                                }
                              }
                            }else{
                              ToastBar(text: 'Please enable location service for continue', color: Colors.red).show();
                              await Geolocator.openLocationSettings();
                            }


                          }, child: CustomText(text: 'Yes',color: Colors.black,)),
                          FlatButton(onPressed: () async {
                            Navigator.pop(context);
                          }, child: CustomText(text: 'No',color: Colors.black,)),
                        ],
                      );
                    }
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(400),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: !logged?Colors.green:Colors.red
                  ),
                  child: Padding(
                    padding:  EdgeInsets.all(ScreenUtil().setSp(40)),
                    child: CustomText(text: !logged?'Login':'Logout',size: ScreenUtil().setSp(70),),
                  ),
                ),
              ),
            ),

            Visibility(
              visible: !logged,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  child: CustomText(text: 'Last logged time - $lastTime',size: ScreenUtil().setSp(35),),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
