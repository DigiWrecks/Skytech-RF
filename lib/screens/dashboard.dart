import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:blinking_text/blinking_text.dart';
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
import 'package:skytech/constants.dart';
import 'package:skytech/screens/log.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/image-button.dart';
import 'package:skytech/widgets/toast.dart';
import 'package:http/http.dart' as http;

import 'admin/locations.dart';
import 'comments.dart';

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
  String location = "";
  bool logged;
  bool isForeman;
  String lastTime;
  double distance;
  String nextLogoutTime = '00:00';
  int index=0;
  int totalMins;
  int budgeted;
  String dueDate;
  bool isShowStayLoggedin = false;

  getLocation() async {
    getDate();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() {
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });
  }

  getDate() async {
    // DateTime now = await NTP.now();
    setState(() {
      // date = DateFormat('MM/dd/yyyy').format(now.toUtc().subtract(Duration(hours: 7)));
      date = DateFormat('MM/dd/yyyy').format(DateTime.now());
    });
  }

  getStayTunedIn() async {
    var sub = await FirebaseFirestore.instance.collection('user').where('email',isEqualTo: widget.email).get();
    var details = sub.docs;
    String timestamp = details[0]['timestamp'];

    var sub2 = await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').where('timestamp',isEqualTo: timestamp).get();
    var logDetail = sub2.docs;
    index = logDetail[0]['index'];
    DateTime loginTime = DateTime.parse(logDetail[0]['timestamp']);
    nextLogoutTime = DateFormat('HH:mm a').format(loginTime.add(Duration(minutes: 480*index)));
    DateTime nextShowingTime = loginTime.add(Duration(minutes: 465*index));
    if(DateTime.now().isAfter(nextShowingTime)){
      isShowStayLoggedin = true;
    }
    else{
      isShowStayLoggedin = false;
    }
    setState(() {});
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
      if(distance < 123){
        setState(() {
          location = workingSites[i]['site'];
          totalMins = workingSites[i]['total'];
          budgeted = workingSites[i]['budgeted'];
          dueDate = workingSites[i]['dueDate'];
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

  onLoginPressed() async {
    print('entering login');
    ToastBar(color: Colors.orange,text: 'Please wait...').show();
    try{
      DateTime now = DateTime.now();
      String time = DateFormat('hh:mm a').format(now);
      String timestamp = now.toString();

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
            'login': time,
            'logout': 'n/a',
            'worked': 'n/a',
            'notes': '',
            'playerId': playerID,
            'popUp': false,
            'index': 1

      }).then((value){
         FirebaseFirestore.instance.collection('user').doc(widget.email).update({
          'logged': true,
          'timestamp': timestamp,
          'locations': locationList
        }).then((value) async {
          ///send request to server
           var url = "http://104.236.53.211:3000/schedule";
           var response = await http.post(
               url,
               headers: <String, String>{
                 'Content-Type': 'application/json',
               },
               body: jsonEncode(<String,dynamic>{
                 'location': location,
                 'playerID': playerID,
                 'email': widget.email,
                 'timestamp': timestamp
               })
           );
           print(response.body+response.statusCode.toString());
           if(response.statusCode==200){
             var body = response.body;
             getStayTunedIn();
             setState(() {
               logged = true;
             });
             ToastBar(color: Colors.green,text: 'Logged in!').show();
           }
           else{
             ToastBar(text: 'Something went wrong while sending data to server!',color: Colors.red).show();
           }
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

     if(distance<123){
       DateTime now = DateTime.now();
       String time = DateFormat('hh:mm a').format(now);
       var durInMins =  now.difference(DateTime.parse(timestamp)).inMinutes;
       var durInHours =  now.difference(DateTime.parse(timestamp)).inHours;
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
       ToastBar(color: Colors.red,text: 'You must within the range of 350ft from your logged in location!').show();
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
    DateTime now = DateTime.now();
    String time = DateFormat('hh:mm a').format(now);
    var durInMins =  now.difference(DateTime.parse(timestamp)).inMinutes;
    var durInHours =  now.difference(DateTime.parse(timestamp)).inHours;
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
    await getStayTunedIn();
    String timestamp = details[0]['timestamp'];
    await getWorkingSites();
    print('before if');
    if (location != locationF) {
      notificationLogOut(timestamp: timestamp, locationF: locationF);
      ToastBar(color: Colors.green, text: 'Logged out!').show();
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
    getStayTunedIn();
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
              CupertinoPageRoute(builder: (context) => Log(email: widget.email,name: widget.name,)),
            );
          })
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(40)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///name and refresh
              SizedBox(height: ScreenUtil().setHeight(40),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///name
                      CustomText(text: 'Hello,',color: Color(0xffE6D5B8),size: ScreenUtil().setSp(35),),
                      CustomText(text: widget.name,size: ScreenUtil().setSp(50),),
                    ],
                  ),

                  ///refresh button
                  GestureDetector(
                    onTap: (){
                      setState(() {
                          location = "";
                      });
                      getWorkingSites();
                      },
                    child: Container(
                      height: ScreenUtil().setHeight(100),
                      width : ScreenUtil().setHeight(100),
                      decoration: BoxDecoration(
                        color: Constants.kButtonBlue,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Icon(Icons.cached,color: Colors.white,size: 35,),
                    ),
                  )
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(20),),

              ///logged status
              if(logged)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding:  EdgeInsets.all(ScreenUtil().setHeight(25)),
                  child: Column(
                    children: [

                      ///you are logged in
                      CustomText(text: 'You are logged in',color: Colors.green,size: ScreenUtil().setSp(30),),
                      SizedBox(height: ScreenUtil().setHeight(20),),

                      ///date and location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ///location
                          CustomText(text: location!=null?location:'',size: ScreenUtil().setSp(40)),
                          ///date
                          CustomText(text: date!=null?date:'',size: ScreenUtil().setSp(40)),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(25),),

                      ///due date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(text: 'Due Date:',size: ScreenUtil().setSp(30),),
                          CustomText(text: dueDate!=null?dueDate:'n/a',size: ScreenUtil().setSp(30),),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(10),),

                      ///due date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(text: 'Projected Completion:',size: ScreenUtil().setSp(30),),
                          CustomText(text: budgeted!=null?(totalMins/budgeted*100).toStringAsFixed(2)+"%":"0.0%",size: ScreenUtil().setSp(30),),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(10),),

                    ],
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(30),),

              ///login time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: 'Date:',size: ScreenUtil().setSp(30),),
                  SizedBox(width: ScreenUtil().setWidth(10),),
                  CustomText(text: date,size: ScreenUtil().setSp(30),),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(15),),

              ///organization
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: 'Organization:',size: ScreenUtil().setSp(30),),
                  SizedBox(width: ScreenUtil().setWidth(10),),
                  CustomText(text: widget.companyName,size: ScreenUtil().setSp(30),),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(15),),

              ///id
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: 'ID Number:',size: ScreenUtil().setSp(30),),
                  SizedBox(width: ScreenUtil().setWidth(10),),
                  CustomText(text: widget.id,size: ScreenUtil().setSp(30),),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(15),),

              ///email
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: 'Email:',size: ScreenUtil().setSp(30),),
                  SizedBox(width: ScreenUtil().setWidth(10),),
                  CustomText(text: widget.email,size: ScreenUtil().setSp(30),),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(15),),

              ///device id
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: 'Device ID:',size: ScreenUtil().setSp(30),),
                  SizedBox(width: ScreenUtil().setWidth(10),),
                  CustomText(text: widget.deviceID,size: ScreenUtil().setSp(30),),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(15),),

              ///lat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: 'Latitude:',size: ScreenUtil().setSp(30),),
                  SizedBox(width: ScreenUtil().setWidth(10),),
                  CustomText(text: lat,size: ScreenUtil().setSp(30),),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(15),),

              ///long
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: 'Longitude:',size: ScreenUtil().setSp(30),),
                  SizedBox(width: ScreenUtil().setWidth(10),),
                  CustomText(text: long,size: ScreenUtil().setSp(30),),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(50),),


              ///detected location
              Visibility(
                visible: !logged,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
                    // child: CustomText(text: location!=null?location:'You are not within the work site!',size: ScreenUtil().setSp(35),),
                    child: BlinkText(
                        location!=null?'LOCATION DETECTED $location':'LOCATION NOT FOUND',
                        style: TextStyle(fontSize: ScreenUtil().setSp(40),fontWeight: FontWeight.bold),
                        beginColor: location!=null?Color(0xff2CE5E5):Color(0xffE56F2C),
                        endColor: Colors.transparent,
                        textAlign: TextAlign.center,
                        duration: Duration(milliseconds: 800)
                    ),
                  ),
                ),
              ),
              if(!logged)
              SizedBox(height: ScreenUtil().setHeight(40),),


              ///add or edit comment
              Visibility(
                visible: logged,
                child: Center(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => Comments(name: widget.name,date: date,location: location,email: widget.email)),
                      );
                    },
                    child: Container(
                      width: ScreenUtil().setWidth(500),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Constants.kButtonBlue
                      ),
                      child: Padding(
                        padding:  EdgeInsets.all(ScreenUtil().setSp(20)),
                        child: CustomText(text: 'Add/Edit Comment',size: ScreenUtil().setSp(40),),
                      ),
                    ),
                  ),
                ),
              ),
              if(logged)
              SizedBox(height: ScreenUtil().setHeight(30),),

              ///stay logged in
              if(isShowStayLoggedin)
              Visibility(
                visible: logged,
                child: Center(
                  child: GestureDetector(
                    onTap: ()async{
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


                        ///get logged timestamp
                        var sub = await FirebaseFirestore.instance.collection('user').where('email',isEqualTo: widget.email).get();
                        var details = sub.docs;

                        String timestamp = details[0]['timestamp'];

                        ///update log to increse mutiplire and true the pop up
                        await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(timestamp).update({
                        'popUp': true,
                        'index': FieldValue.increment(1)
                        });

                        ///get onesignalId
                        String playerID;
                        await OneSignal.shared.getPermissionSubscriptionState().then((result) {
                        playerID = result.subscriptionStatus.userId;
                        });

                        ///getCurrentTimestamp
                        DateTime now = DateTime.now();
                        String currentTimestamp = now.toString();

                        ///send request to server
                        var url = "http://104.236.53.211:3000/reschedule";
                        var response = await http.post(
                            url,
                          headers: <String, String>{
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode(<String,dynamic>{
                            'lastLogin': currentTimestamp,
                            'location': location,
                            'playerID': playerID,
                            'email': widget.email,
                            'timestamp': timestamp
                          })
                        );
                        print(response.body+response.statusCode.toString());
                        if(response.statusCode==200){
                          await pr.hide();
                          var body = response.body;
                          await getStayTunedIn();
                          ToastBar(text: 'Data updated!',color: Colors.green).show();
                        }
                        else{
                          await pr.hide();
                          ToastBar(text: 'Something went wrong!',color: Colors.red).show();
                        }
                    },
                    child: Container(
                      width: ScreenUtil().setWidth(500),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xffE56F2C)
                      ),
                      child: Padding(
                        padding:  EdgeInsets.all(ScreenUtil().setSp(20)),
                        child: Column(
                          children: [
                            BlinkText(
                              'You will be logged out at $nextLogoutTime',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(25)),
                              beginColor: Colors.white,
                              endColor: Color(0xffE56F2C),
                              duration: Duration(milliseconds: 600),
                            ),
                            SizedBox(height: ScreenUtil().setHeight(10),),
                            BlinkText(
                              'STAY LOGGED IN',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(40)),
                              beginColor: Colors.white,
                              endColor: Color(0xffE56F2C),
                              duration: Duration(milliseconds: 600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if(logged&&isShowStayLoggedin)
              SizedBox(height: ScreenUtil().setHeight(30),),


              ///log button
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
                                  if(location!=null){
                                    if(!logged){
                                      onLoginPressed();
                                      print('login button pressed entering to login');
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
                    width: ScreenUtil().setWidth(500),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: !logged?Color(0xff52C76E):Color(0xffC82959)
                    ),
                    child: Padding(
                      padding:  EdgeInsets.all(ScreenUtil().setSp(40)),
                      child: CustomText(text: !logged?'Login':'Logout',size: ScreenUtil().setSp(70),),
                    ),
                  ),
                ),
              ),

              ///last logged time
              Visibility(
                visible: !logged,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    child: CustomText(text: 'Last logged time - $lastTime',size: ScreenUtil().setSp(35),),
                  ),
                ),
              ),


              ///locations
              SizedBox(height: ScreenUtil().setHeight(40),),
              Center(
                child: Container(
                  width: ScreenUtil().setWidth(250),
                  child: ImageButton(
                    color: Color(0xffC4C4C4),
                    image: 'location.png',
                    text: 'Locations',
                    onclick: (){
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => Locations(email: widget.companyEmail,)),
                      );
                    },
                    textColor: Colors.black,
                  ),
                ),
              )


            ],
          ),
        ),
      ),

    );
  }
}
