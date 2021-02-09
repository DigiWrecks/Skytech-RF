import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:skytech/constants.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/toast.dart';


class SettingsScreen extends StatefulWidget {

  final String code;
  final String email;
  const SettingsScreen({Key key, this.code, this.email}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController newLocation = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();
  TextEditingController budgetedHoursControllers = TextEditingController();
  String date = 'Pick the Due Date';

  popUpCard(BuildContext context,String type) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            title: CustomText(text: type=='insert'?'Add new Location':'Update Location',align: TextAlign.center,color: Colors.black,),
            content: Container(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ///name
                    TextField(
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: 'Enter New Location',
                        enabledBorder:UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 5),
                        ),
                      ),
                      controller: newLocation,
                    ),
                    SizedBox(height: 20,),

                    ///latitude
                    TextField(
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.numberWithOptions(decimal: true,signed: true),
                      decoration: InputDecoration(
                        hintText: 'Lat',
                        enabledBorder:UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 5),
                        ),
                      ),
                      controller: latController,
                    ),
                    SizedBox(height: 20,),

                    ///longitude
                    TextField(
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.numberWithOptions(decimal: true,signed: true),
                      decoration: InputDecoration(
                        hintText: 'Long',
                        enabledBorder:UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 5),
                        ),
                      ),
                      controller: longController,
                    ),
                    SizedBox(height: 20,),

                    ///budgeted hours
                    TextField(
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Budgeted Hours',
                        enabledBorder:UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 5),
                        ),
                      ),
                      controller: budgetedHoursControllers,
                    ),
                    SizedBox(height: 20,),

                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(40)),
                      child: Button(text: date,color: Constants.kButtonBlue,onclick: () async {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (_) => Container(
                              height: MediaQuery.of(context).size.height/2,
                              child: CupertinoDatePicker(
                                onDateTimeChanged: (x){
                                  setState(() {
                                    date = DateFormat('MM/dd/yyyy').format(x);
                                  });
                                },
                                mode: CupertinoDatePickerMode.date,
                                backgroundColor: Colors.white,
                              ),
                            ));
                      }),
                    ),


                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(40)),
                      child: Button(text: 'Fetch',color: Colors.amber,onclick: () async {
                        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
                        setState(() {
                          latController.text = position.latitude.toString();
                          longController.text = position.longitude.toString();
                        });
                      }),
                    ),
                    Padding(
                      padding:  EdgeInsets.all(ScreenUtil().setHeight(40)),
                      child: Button(text: type=='insert'?'Add':'Update',color: Colors.red,onclick: () async {
                        if(newLocation.text.isNotEmpty && latController.text.isNotEmpty && longController.text.isNotEmpty && budgetedHoursControllers.text.isNotEmpty && date!='Pick the Due Date'){
                          if(type=='insert'){
                            locationList.add(newLocation.text);
                            await FirebaseFirestore.instance.collection('admin').doc(widget.email).update({
                              'sites': locationList
                            });
                            await FirebaseFirestore.instance.collection('admin').doc(widget.email).collection('sites').doc(newLocation.text).set(
                                {
                                  'site': newLocation.text,
                                  'lat': double.parse(latController.text),
                                  'long': double.parse(longController.text),
                                  'budgeted': int.parse(budgetedHoursControllers.text)*60,
                                  'dueDate': date,
                                  'total': 0
                                }
                            );
                            latController.clear();
                            longController.clear();
                            newLocation.clear();
                            Navigator.pop(context);
                          }
                          else{
                            if(!locationList.contains(newLocation.text)){
                              locationList.add(newLocation.text);
                              await FirebaseFirestore.instance.collection('admin').doc(widget.email).update({
                                'sites': locationList
                              });
                            }
                            await FirebaseFirestore.instance.collection('admin').doc(widget.email).collection('sites').doc(newLocation.text).update(
                                {
                                  'site': newLocation.text,
                                  'lat': double.parse(latController.text),
                                  'long': double.parse(longController.text),
                                  'budgeted': int.parse(budgetedHoursControllers.text)*60,
                                  'dueDate': date,
                                }
                            );

                            latController.clear();
                            longController.clear();
                            newLocation.clear();
                            Navigator.pop(context);
                          }
                        }
                        else{
                          ToastBar(text: "Please fill all the fields",color: Colors.red).show();
                        }

                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
        },
    );
  }

  String durationToString(int minutes) {
    var d = Duration(minutes:minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  final CollectionReference collectionReference  = FirebaseFirestore.instance.collection("admin");
  List<DocumentSnapshot> workSitesList;
  StreamSubscription<QuerySnapshot> subscription;
  List locationList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription = collectionReference.doc(widget.email).collection('sites').snapshots().listen((datasnapshot){
      setState(() {
        locationList.clear();
        workSitesList = datasnapshot.docs;
        workSitesList.forEach((element) {
          locationList.add(element['site']);
        });
      });
    });
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
        title: CustomText(text: 'Settings'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: ()=>popUpCard(context,'insert'),
        child: Icon(Icons.add),
        backgroundColor: Constants.kButtonBlue,
        elevation: 9,

      ),

      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
        child: Column(
          children: [
            ///companyCode
            Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(35)),
              child: CustomText(text: 'Company Code',size: ScreenUtil().setSp(35),),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                child: CustomText(text: widget.code,size: ScreenUtil().setSp(30),),
              ),
            ),

            ///title of workTime and workStie
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Padding(
            //       padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(35)),
            //       child: CustomText(text: 'Work Sites',size: ScreenUtil().setSp(35),),
            //     ),
            //     Padding(
            //       padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(35)),
            //       child: CustomText(text: 'Work Time',size: ScreenUtil().setSp(35),),
            //     ),
            //   ],
            // ),

            SizedBox(height: ScreenUtil().setHeight(35),),

            ///listviews
            Expanded(
              child: workSitesList!=null?ListView.builder(
                itemCount: workSitesList.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context,i){
                  String location = workSitesList[i]['site'];
                  String hours = durationToString(workSitesList[i]['total']);
                  String lat = workSitesList[i]['lat'].toString();
                  String long = workSitesList[i]['long'].toString();
                  String dueDate = workSitesList[i]['dueDate'].toString();
                  String budgeted = durationToString(workSitesList[i]['budgeted']);

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

                            ///location
                            CustomText(text: location,size: ScreenUtil().setSp(35)),

                            ///due date
                            Padding(
                              padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(text: 'Due Date:',size: ScreenUtil().setSp(30),),
                                  CustomText(text: dueDate,size: ScreenUtil().setSp(30),),
                                ],
                              ),
                            ),

                            ///budgeted hours
                            Padding(
                              padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(text: 'Budgeted Hours:',size: ScreenUtil().setSp(30),),
                                  CustomText(text: budgeted+' H',size: ScreenUtil().setSp(30),),
                                ],
                              ),
                            ),

                            ///accumulated hours
                            Padding(
                              padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(text: 'Accumulated Hours:',size: ScreenUtil().setSp(30),),
                                  CustomText(text: hours+' H',size: ScreenUtil().setSp(30),),
                                ],
                              ),
                            ),

                            ///latitude
                            Padding(
                              padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(text: 'Latitude:',size: ScreenUtil().setSp(30),),
                                  CustomText(text: lat,size: ScreenUtil().setSp(30),),
                                ],
                              ),
                            ),

                            ///longitude
                            Padding(
                              padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(text: 'Longitude:',size: ScreenUtil().setSp(30),),
                                  CustomText(text: long,size: ScreenUtil().setSp(30),),
                                ],
                              ),
                            ),


                            ///buttons
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                                    child: Button(
                                      text: 'Delete',
                                      color: Colors.red,
                                      onclick: () async {
                                        locationList.remove(location);
                                        await FirebaseFirestore.instance.collection('admin').doc(widget.email).update({
                                          'sites': locationList
                                        });
                                        await FirebaseFirestore.instance.collection('admin').doc(widget.email).collection('sites').doc(location).delete();
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                                    child: Button(
                                      text: 'Edit',
                                      color: Colors.green,
                                      onclick: (){
                                        newLocation.text = location;
                                        latController.text = lat;
                                        longController.text = long;
                                        budgetedHoursControllers.text = (workSitesList[i]['budgeted']/60).round().toString();
                                        date=dueDate;
                                        popUpCard(context,'update');
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),

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
