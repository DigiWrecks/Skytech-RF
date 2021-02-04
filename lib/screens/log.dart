import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:intl/intl.dart';
import 'package:skytech/widgets/custom-text.dart';

class Log extends StatefulWidget {
  final String email;
  final String name;

  const Log({Key key, this.email, this.name}) : super(key: key);

  @override
  _LogState createState() => _LogState();
}

class _LogState extends State<Log> {


  List<DocumentSnapshot> logs;
  StreamSubscription<QuerySnapshot> subscription;

  getNTP() async {
    DateTime now = DateTime.now();
    String lastDate = DateFormat('MM/dd/yyyy').format(now.subtract(Duration(days:7)));
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///name
            CustomText(text: 'Hello,',color: Color(0xffE6D5B8),size: ScreenUtil().setSp(35),),
            CustomText(text: widget.name,size: ScreenUtil().setSp(50),),
            SizedBox(height: ScreenUtil().setHeight(40),),

            ///logs
            Expanded(
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
                    padding:  EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding:  EdgeInsets.all(ScreenUtil().setHeight(25)),
                        child: Column(
                          children: [

                            ///date and location
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ///date
                                CustomText(text: date,size: ScreenUtil().setSp(40)),
                                SizedBox(height: ScreenUtil().setHeight(20),),

                                ///location
                                CustomText(text: location,size: ScreenUtil().setSp(40)),
                              ],
                            ),
                            SizedBox(height: ScreenUtil().setHeight(25),),


                            ///login time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(text: 'Login Time:',size: ScreenUtil().setSp(30),),
                                SizedBox(width: ScreenUtil().setWidth(10),),
                                CustomText(text: login,size: ScreenUtil().setSp(30),),
                              ],
                            ),
                            SizedBox(height: ScreenUtil().setHeight(10),),

                            ///login long
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(text: 'Login Longitude:',size: ScreenUtil().setSp(30),),
                                SizedBox(width: ScreenUtil().setWidth(10),),
                                CustomText(text: logInlong,size: ScreenUtil().setSp(30),),
                              ],
                            ),
                            SizedBox(height: ScreenUtil().setHeight(10),),

                            ///login lat
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(text: 'Login Latitude:',size: ScreenUtil().setSp(30),),
                                SizedBox(width: ScreenUtil().setWidth(10),),
                                CustomText(text: logInlat,size: ScreenUtil().setSp(30),),
                              ],
                            ),
                            SizedBox(height: ScreenUtil().setHeight(35),),

                            ///logout time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(text: 'Logout Time:',size: ScreenUtil().setSp(30),),
                                SizedBox(width: ScreenUtil().setWidth(10),),
                                CustomText(text: logout,size: ScreenUtil().setSp(30),),
                              ],
                            ),
                            SizedBox(height: ScreenUtil().setHeight(10),),

                            ///logout long
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(text: 'Logout Longitude:',size: ScreenUtil().setSp(30),),
                                SizedBox(width: ScreenUtil().setWidth(10),),
                                CustomText(text: logOutlong,size: ScreenUtil().setSp(30),),
                              ],
                            ),
                            SizedBox(height: ScreenUtil().setHeight(10),),

                            ///logout lat
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(text: 'Logout Latitude:',size: ScreenUtil().setSp(30),),
                                SizedBox(width: ScreenUtil().setWidth(10),),
                                CustomText(text: logOutlat,size: ScreenUtil().setSp(30),),
                              ],
                            ),
                            SizedBox(height: ScreenUtil().setHeight(10),),
                          ],
                        ),
                      ),
                    ),
                  );
                  },
              ):Center(child: CircularProgressIndicator()),
            )
          ],
        ),
      ),
    );
  }
}
