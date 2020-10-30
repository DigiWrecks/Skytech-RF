import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';


class SettingsScreen extends StatefulWidget {

  final String code;
  const SettingsScreen({Key key, this.code}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController newLocation = TextEditingController();

  popUpCard(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: CustomText(text: 'Add new Location',align: TextAlign.center,color: Colors.black,),
          content: Container(
            height: ScreenUtil().setHeight(280),
            child: Column(
              children: [
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
                Padding(
                  padding:  EdgeInsets.all(ScreenUtil().setHeight(40)),
                  child: Button(text: 'Add',color: Colors.red,onclick: () async {
                    locationList.add(newLocation.text);
                    await FirebaseFirestore.instance.collection('admin').doc(workSitesList[0]['email']).update({
                      'sites': locationList
                    });
                    Navigator.pop(context);
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  final CollectionReference collectionReference  = FirebaseFirestore.instance.collection("admin");
  List<DocumentSnapshot> workSitesList;
  StreamSubscription<QuerySnapshot> subscription;
  List locationList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription = collectionReference.where('code', isEqualTo: widget.code).snapshots().listen((datasnapshot){
      setState(() {
        workSitesList = datasnapshot.docs;
        locationList = workSitesList[0]['sites'];
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
        onPressed: ()=>popUpCard(context),
        child: Icon(Icons.add),
        backgroundColor: Color(0xffE6D5B8),
        elevation: 9,

      ),

      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(35)),
              child: CustomText(text: 'Company Code',size: ScreenUtil().setSp(35),),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                child: CustomText(text: widget.code,color: Colors.black,size: ScreenUtil().setSp(30),),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(35)),
              child: CustomText(text: 'Work Sites',size: ScreenUtil().setSp(35),),
            ),
            Expanded(
              child: workSitesList!=null?ListView.builder(
                itemCount: locationList.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context,i){
                  String location = locationList[i];
                  return Padding(
                    padding:  EdgeInsets.only(bottom: ScreenUtil().setHeight(25)),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                              child: CustomText(text: location,color: Colors.black,size: ScreenUtil().setSp(30),),
                            ),
                          ),
                          IconButton(icon: Icon(Icons.delete), onPressed: () async {
                                  locationList.removeAt(i);
                                  await FirebaseFirestore.instance.collection('admin').doc(workSitesList[0]['email']).update({
                                    'sites': locationList
                                  });
                          })
                        ],
                      ),
                    ),
                  );
                },
              ):CircularProgressIndicator(),
            )
          ],
        ),
      ),


    );
  }
}
