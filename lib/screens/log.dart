import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';

class Log extends StatefulWidget {
  final String email;

  const Log({Key key, this.email}) : super(key: key);

  @override
  _LogState createState() => _LogState();
}

class _LogState extends State<Log> {


  List<DocumentSnapshot> logs;
  StreamSubscription<QuerySnapshot> subscription;

  getNTP() async {
    DateTime now = await NTP.now();
    String lastDate = DateFormat('MM/dd/yyyy').format(now.toUtc().subtract(Duration(hours: 7)).subtract(Duration(days:7)));
    CollectionReference collectionReference  = FirebaseFirestore.instance.collection("logs").doc(widget.email).collection('logs');
    subscription = collectionReference.where('date',isGreaterThanOrEqualTo: lastDate).orderBy('date',descending: true).snapshots().listen((datasnapshot){
      setState(() {
        logs = datasnapshot.docs;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Firebase.initializeApp();
    getNTP();

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
        title: CustomText(text: 'Logs'),
      ),

      body: Padding(
        padding:  EdgeInsets.all(ScreenUtil().setHeight(30)),
        child: logs!=null?ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: logs.length,
          itemBuilder: (context,i){
            String date = logs[i]['date'];
            String logInlat = logs[i]['loginLat'];
            String logOutlat = logs[i]['logoutLat'];
            String logInlong = logs[i]['loginLong'];
            String logOutlong = logs[i]['logoutLong'];
            String login = logs[i]['login'];
            String logout = logs[i]['logout'];
            String location = logs[i]['location'];


            return Padding(
              padding:  EdgeInsets.only(bottom: ScreenUtil().setHeight(25)),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff99A8B2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding:  EdgeInsets.all(ScreenUtil().setHeight(25)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,size: 25,),
                          SizedBox(width: ScreenUtil().setWidth(20),),
                          CustomText(text: date,size: ScreenUtil().setSp(35),color: Colors.black,),


                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(20),),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            ///login & logout
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
                                        border: Border.all(color: Colors.white,width: 3)
                                    ),
                                    child: Padding(
                                      padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
                                      child: CustomText(text: 'Login:-$login',size: ScreenUtil().setSp(30),color: Colors.black,),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(10)),
                                        border: Border.all(color: Colors.white,width: 3)
                                    ),
                                    child: Padding(
                                      padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
                                      child: CustomText(text: 'Logout:- $logout',size: ScreenUtil().setSp(30),color: Colors.black,),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            ///blueBox
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white,width: 3),
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10))
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:  EdgeInsets.all(ScreenUtil().setWidth(10)),
                                          child: CustomText(text: 'Lat : ${(double.parse(logInlat)).toStringAsFixed(5)}',size: ScreenUtil().setSp(30),color: Colors.black,),
                                        ),
                                        Padding(
                                          padding:  EdgeInsets.all(ScreenUtil().setWidth(10)),
                                          child: CustomText(text: 'Long : ${(double.parse(logInlong)).toStringAsFixed(5)}',size: ScreenUtil().setSp(30),color: Colors.black,),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white,width: 3),
                                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(10))
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:  EdgeInsets.all(ScreenUtil().setWidth(10)),
                                          child: CustomText(text: 'Lat : ${(double.parse(logOutlat)).toStringAsFixed(5)}',size: ScreenUtil().setSp(30),color: Colors.black,),
                                        ),
                                        Padding(
                                          padding:  EdgeInsets.all(ScreenUtil().setWidth(10)),
                                          child: CustomText(text: 'Long : ${(double.parse(logOutlong)).toStringAsFixed(5)}',size: ScreenUtil().setSp(30),color: Colors.black,),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding:  EdgeInsets.all(ScreenUtil().setWidth(20)),
                              child: CustomText(text: 'Location : $location',size: ScreenUtil().setSp(35),color: Colors.black,),
                            ),

                            SizedBox(height: ScreenUtil().setHeight(10),)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ):Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
