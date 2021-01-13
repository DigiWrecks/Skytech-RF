import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/toast.dart';

class UserAnalytics extends StatefulWidget {
  final String name;
  final String email;
  final String workSite;
  final int totalMins;
  final String adminEmail;

  const UserAnalytics({Key key, this.name, this.email, this.workSite, this.totalMins, this.adminEmail}) : super(key: key);
  @override
  _UserAnalyticsState createState() => _UserAnalyticsState();
}

class _UserAnalyticsState extends State<UserAnalytics> {

  List<DocumentSnapshot> status;
  List<DocumentSnapshot> logs;
  StreamSubscription<QuerySnapshot> subscription;
  StreamSubscription<QuerySnapshot> subscription2;
  bool logged = false;
  String timestamp;
  String deviceID;

  getStatus(){
    subscription = FirebaseFirestore.instance.collection('user').where('email', isEqualTo: widget.email).snapshots().listen((datasnapshot){
      setState(() {
        status = datasnapshot.docs;
        logged = status[0]['logged'];
        timestamp = status[0]['timestamp'];
        deviceID = status[0]['deviceId'];
      });
    });
  }

  getLog(){
    if(widget.workSite=='All'){
      subscription2 = FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').orderBy('timestamp',descending: true).snapshots().listen((datasnapshot){
        setState(() {
          logs = datasnapshot.docs;
        });
      });
    }
    else{
      subscription2 = FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').where('location', isEqualTo: widget.workSite).orderBy('timestamp',descending: true).snapshots().listen((datasnapshot){
        setState(() {
          logs = datasnapshot.docs;
        });
      });
    }
    
  }

  logOutUser() async {
    ToastBar(color: Colors.orange,text: 'Please wait...').show();
    try{
      DateTime now = await NTP.now();
        String time = DateFormat('hh:mm a').format(now.toUtc().subtract(Duration(hours: 7)));
        var durInMins =  now.toUtc().subtract(Duration(hours: 7)).difference(DateTime.parse(timestamp)).inMinutes;
        var durInHours =  now.toUtc().subtract(Duration(hours: 7)).difference(DateTime.parse(timestamp)).inHours;
        int mins = durInMins - durInHours*60;
        // print(durInHours.toString()+" h "+mins.toString()+" min");

      await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(timestamp).update({
          'logout': time,
          'logoutLat': "0",
          'logoutLong': "0",
          'notes': '',
          'worked': durInHours.toString()+" h "+mins.toString()+" min"
        });

        await FirebaseFirestore.instance.collection('user').doc(widget.email).update({
          'logged': false,
          'lastTime': durInHours.toString()+" h "+mins.toString()+" min"
        });

        await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(timestamp).get().then((value) async {
          var sub = await FirebaseFirestore.instance.collection('admin').doc(widget.adminEmail).collection('sites').where('site', isEqualTo: value['location']).get();
          var site  = sub.docs;
          if(site.isNotEmpty){
            int total = site[0]['total'];
            total = total+durInMins;
            await FirebaseFirestore.instance.collection('admin').doc(widget.adminEmail).collection('sites').doc(value['location']).update({
              'total': total,
            });
          }
        });




        setState(() {
          logged = false;
        });
        ToastBar(color: Colors.green,text: 'Logged out!').show();
    }
    catch(e){
      ToastBar(color: Colors.red,text: e.toString()).show();
    }
  }

  popUpCard(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: CustomText(text: 'Device ID',align: TextAlign.center,color: Colors.black,),
          content: Container(
            height: ScreenUtil().setHeight(290),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color(0xff99A8B2),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                    child: CustomText(text: deviceID,color: Colors.white,size: ScreenUtil().setSp(30),),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.all(ScreenUtil().setHeight(40)),
                  child: Button(text: 'Remove ID',color: Colors.red,onclick: () async {
                    try{
                      await FirebaseFirestore.instance.collection('user').doc(widget.email).update({
                        'deviceId': ''
                      });
                      ToastBar(color: Colors.green,text: 'Device ID Removed!').show();
                      Navigator.pop(context);
                    }
                    catch(e){
                      ToastBar(color: Colors.red,text: 'Something went wrong!').show();
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

  onEditing({String docId,String login,String logout,String lat,String long}) async {
    await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(docId).update({
      'login': login,
      'logout': logout,
      'lat': lat,
      'long': long
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStatus();
    getLog();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();
    subscription2?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'User Analytics'),
        actions: [
          IconButton(icon: Icon(Icons.phonelink_setup), onPressed: ()=>popUpCard(context))
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
            child: Row(
              children: [
                Icon(Icons.account_circle_outlined,color: Colors.white,size: 35,),
                SizedBox(width: ScreenUtil().setWidth(20),),
                Flexible(
                    child: CustomText(text: widget.name,size: ScreenUtil().setSp(50),)),
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(left: ScreenUtil().setWidth(40)),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40)
              ),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setHeight(15)),
                child: CustomText(text: logged?'Logged In':'Logged Out',color: logged?Colors.green:Colors.red,size: ScreenUtil().setSp(30),),
              ),
            ),
          ),

          Visibility(
            visible: logged,
            child: Padding(
              padding:  EdgeInsets.all(ScreenUtil().setHeight(40)),
              child: Button(text: 'Logout User',color: Colors.red,onclick: ()=>logOutUser()),
            ),
          ),

          Expanded(
            child: Padding(
              padding:  EdgeInsets.all(ScreenUtil().setHeight(30)),
              child: logs!=null?ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context,i){
                  TextEditingController loginEdit = TextEditingController();
                  TextEditingController logoutEdit = TextEditingController();
                  TextEditingController loginLatEdit = TextEditingController();
                  TextEditingController logoutLatEdit = TextEditingController();
                  TextEditingController loginLongEdit = TextEditingController();
                  TextEditingController logoutLongEdit = TextEditingController();

                    loginEdit.text = logs[i]['login'];
                    logoutEdit.text = logs[i]['logout'];

                    loginLatEdit.text = (double.parse(logs[i]['loginLat'])).toStringAsFixed(5);
                    logoutLatEdit.text = (double.parse(logs[i]['logoutLat'])).toStringAsFixed(5);
                    loginLongEdit.text = (double.parse(logs[i]['loginLong'])).toStringAsFixed(5);
                    logoutLongEdit.text = (double.parse(logs[i]['logoutLong'])).toStringAsFixed(5);



                  String location = logs[i]['location'];
                  String worked = logs[i]['worked'];
                  String date = logs[i]['date'];
                  String note = logs[i]['notes'];
                  bool overtime = logs[i]['overtime'];
                  return Padding(
                    padding:  EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xff99A8B2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding:  EdgeInsets.all(ScreenUtil().setHeight(25)),
                        child: Column(
                          children: [
                            ///date
                            Row(
                              children: [
                                Icon(Icons.calendar_today,size: 25,),
                                SizedBox(width: ScreenUtil().setWidth(20),),
                                CustomText(text: date,size: ScreenUtil().setSp(35),color: Colors.black,),
                                Expanded(child: Container()),
                                overtime?Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Colors.red
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                                      child: CustomText(text: 'Overtime',color: Colors.white,),
                                    ),
                                  ),
                                ):Container()
                              ],
                            ),
                            SizedBox(height: ScreenUtil().setHeight(20),),

                            ///blueBox
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///login andd logout time
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xffc4c4c4),
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
                                              border: Border.all(color: Colors.white,width: 3)
                                          ),
                                          child: Padding(
                                            padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
                                            child: Row(
                                              children: [
                                                CustomText(text: 'Login:-',size: ScreenUtil().setSp(30),color: Colors.black,),
                                                SizedBox(width: ScreenUtil().setWidth(10),),
                                                Expanded(
                                                  child: TextField(
                                                    controller: loginEdit,
                                                    cursorColor: Colors.black,
                                                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30)),
                                                    decoration: InputDecoration(
                                                      hintText: '00:00',
                                                      enabledBorder:InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                    ),
                                                    onSubmitted: (x) async {
                                                      await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(logs[i].id).update({
                                                        'login': x,
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xffc4c4c4),
                                              borderRadius: BorderRadius.only(topRight: Radius.circular(10)),
                                              border: Border.all(color: Colors.white,width: 3)
                                          ),
                                          child: Padding(
                                            padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
                                            child: Row(
                                              children: [
                                                CustomText(text: 'Logout:-',size: ScreenUtil().setSp(30),color: Colors.black,),
                                                SizedBox(width: ScreenUtil().setWidth(10),),
                                                Expanded(
                                                  child: TextField(
                                                    controller: logoutEdit,
                                                    cursorColor: Colors.black,
                                                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30)),
                                                    decoration: InputDecoration(
                                                      hintText: '00:00',
                                                      enabledBorder:InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                    ),
                                                    onSubmitted: (x) async {
                                                      await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(logs[i].id).update({
                                                        'logout': x,
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ///lat and long
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Theme.of(context).accentColor,
                                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
                                              border: Border.all(color: Colors.white,width: 3)
                                          ),
                                          child: Padding(
                                            padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    CustomText(text: 'Lat:-',size: ScreenUtil().setSp(30),color: Colors.black,),
                                                    SizedBox(width: ScreenUtil().setWidth(10),),
                                                    Expanded(
                                                      child: TextField(
                                                        controller: loginLatEdit,
                                                        cursorColor: Colors.black,
                                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30)),
                                                        decoration: InputDecoration(
                                                          hintText: 'n/a',
                                                          enabledBorder:InputBorder.none,
                                                          focusedBorder: InputBorder.none,
                                                        ),
                                                        onSubmitted: (x) async {
                                                          await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(logs[i].id).update({
                                                            'loginLat': x,
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    CustomText(text: 'Long:-',size: ScreenUtil().setSp(30),color: Colors.black,),
                                                    SizedBox(width: ScreenUtil().setWidth(10),),
                                                    Expanded(
                                                      child: TextField(
                                                        controller: loginLongEdit,
                                                        cursorColor: Colors.black,
                                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30)),
                                                        decoration: InputDecoration(
                                                          hintText: 'n/a',
                                                          enabledBorder:InputBorder.none,
                                                          focusedBorder: InputBorder.none,
                                                        ),
                                                        onSubmitted: (x) async {
                                                          await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(logs[i].id).update({
                                                            'loginLong': x,
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Theme.of(context).accentColor,
                                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)),
                                              border: Border.all(color: Colors.white,width: 3)
                                          ),
                                          child: Padding(
                                            padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    CustomText(text: 'Lat:-',size: ScreenUtil().setSp(30),color: Colors.black,),
                                                    SizedBox(width: ScreenUtil().setWidth(10),),
                                                    Expanded(
                                                      child: TextField(
                                                        controller: logoutLatEdit,
                                                        cursorColor: Colors.black,
                                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30)),
                                                        decoration: InputDecoration(
                                                          hintText: 'n/a',
                                                          enabledBorder:InputBorder.none,
                                                          focusedBorder: InputBorder.none,
                                                        ),
                                                        onSubmitted: (x) async {
                                                          await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(logs[i].id).update({
                                                            'logoutLat': x,
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    CustomText(text: 'Long:-',size: ScreenUtil().setSp(30),color: Colors.black,),
                                                    SizedBox(width: ScreenUtil().setWidth(10),),
                                                    Expanded(
                                                      child: TextField(
                                                        controller: logoutLongEdit,
                                                        cursorColor: Colors.black,
                                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(30)),
                                                        decoration: InputDecoration(
                                                          hintText: 'n/a',
                                                          enabledBorder:InputBorder.none,
                                                          focusedBorder: InputBorder.none,
                                                        ),
                                                        onSubmitted: (x) async {
                                                          await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(logs[i].id).update({
                                                            'logoutLong': x,
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: ScreenUtil().setHeight(25),),
                                  ///location
                                  Padding(
                                    padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(28)),
                                    child: CustomText(text: 'Location : $location',size: ScreenUtil().setSp(35),color: Colors.black,),
                                  ),
                                  SizedBox(height: ScreenUtil().setHeight(45),),
                                  ///workedTime
                                  Padding(
                                    padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(28)),
                                    child: CustomText(text: 'Worked Time : $worked',size: ScreenUtil().setSp(35),color: Colors.black,),
                                  ),
                                  SizedBox(height: ScreenUtil().setHeight(30),)
                                ],
                              ),
                            ),

                            ///NoteText
                            SizedBox(height: ScreenUtil().setHeight(20),),
                            Align(
                                alignment: Alignment.topLeft,
                                child: CustomText(text: 'Note',size: ScreenUtil().setSp(40),color: Colors.black,)),

                            ///Note
                            SizedBox(height: ScreenUtil().setHeight(20),),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                                child: CustomText(text: note,color: Colors.black,size: ScreenUtil().setSp(35),),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ):Center(child: CircularProgressIndicator(),),
            ),
          ),

        ],
      ),
    );
  }
}
