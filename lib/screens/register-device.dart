import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:ntp/ntp.dart';
import 'package:skytech/screens/dashboard.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/inputfield.dart';
import 'package:skytech/widgets/toast.dart';

class RegisterDevice extends StatefulWidget {
  @override
  _RegisterDeviceState createState() => _RegisterDeviceState();
}

class _RegisterDeviceState extends State<RegisterDevice> {

  TextEditingController name = TextEditingController();
  TextEditingController code = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController id = TextEditingController();
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

  List userList = [];
  List deviceList = [];
  String companyEmail;

  registerDevice() async {
    await Firebase.initializeApp();
    if(email.text!='' && id.text!='' && name.text!=''&& code.text!=''){
      ToastBar(color: Colors.orange,text: 'Please wait...').show();

      try{

        var sub = await FirebaseFirestore.instance.collection('admin').where('code',isEqualTo: code.text).get();
        var companies = sub.docs;

        var sub2 = await FirebaseFirestore.instance.collection('user').where('email',isEqualTo: email.text).get();
        var users = sub2.docs;

        if(users.isEmpty){
          if(companies.isNotEmpty){
              userList = companies[0]['users'];
              deviceList = companies[0]['devices'];
              companyEmail = companies[0]['email'];
              userList.add(email.text);
              deviceList.add(deviceID);

              DateTime time = await NTP.now();

            await FirebaseFirestore.instance.collection('user').doc(email.text).set({
              'name': name.text,
              'email': email.text,
              'code': code.text,
              'id': id.text,
              'deviceId': deviceID,
              'logged': false,
              'timestamp': time.toUtc().subtract(Duration(hours: 7)).toString(),
              'lastTime': '0h 0min',
              'locations': []
            });

            await FirebaseFirestore.instance.collection('admin').doc(companies[0].id).update({
              'users': userList,
              'devices': deviceList
            });

            ToastBar(color: Colors.green,text: 'Device Registered!').show();
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (context) => DashBoard(name: name.text,deviceID: deviceID,id: id.text,companyName: companies[0]['fname']+' '+companies[0]['lname'],code: code.text,email: email.text,isLogged: false,lastTime: '0h 0min',companyEmail: companyEmail,)),
            );
          }
          else{
            ToastBar(color: Colors.red,text: 'Company Doesn\'t Exists!').show();
          }
        }
        else{
          if(users[0]['deviceId']==''||users[0]['deviceId']==null){
            await FirebaseFirestore.instance.collection('user').doc(email.text).update({
              'deviceId': deviceID
            });
            ToastBar(color: Colors.green,text: 'Device Updated!').show();
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (context) => DashBoard(deviceID: deviceID,companyName: companies[0]['name'],id: users[0]['id'],name: users[0]['name'],code: companies[0]['code'],email: users[0]['email'],isLogged: users[0]['logged'],lastTime: users[0]['lastTime'],)),
            );
          }
          else{
            ToastBar(color: Colors.red,text: 'Your account is already registered on another device!').show();
          }

        }
      }
        catch(e){
          ToastBar(color: Colors.red,text: 'Something went wrong!').show();
          print("error is"+e.toString());
        }

    }else{
      ToastBar(color: Colors.red,text: 'Please Fill all the Fields!').show();
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceID();
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,elevation: 0,),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                CustomText(text: 'Register your device',size: ScreenUtil().setSp(60)),

                InputField(hint: 'Name',controller: name,),
                InputField(hint: 'Email',type: TextInputType.emailAddress,controller: email,),
                InputField(hint: 'ID Number',controller: id,),
                InputField(hint: 'Company Code',controller: code,),
              
                Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(35)),
                  child: CustomText(text: 'Device ID',size: ScreenUtil().setSp(35),),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                    child: CustomText(text: deviceID,color: Colors.black,size: ScreenUtil().setSp(30),),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
                  child: Button(text: 'Register',onclick: ()=>registerDevice(),),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
