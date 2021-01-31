import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:ntp/ntp.dart';
import 'package:skytech/constants.dart';
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

  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController code = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController id = TextEditingController();
  String deviceID = 'N/A';
  bool isForeman = false;

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
    if(email.text!='' && id.text!='' && fname.text!=''&& lname.text!=''&&code.text!=''){
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

              DateTime time = DateTime.now();

            await FirebaseFirestore.instance.collection('user').doc(email.text).set({
              'fname': fname.text,
              'lname': lname.text,
              'email': email.text,
              'code': code.text,
              'id': id.text,
              'deviceId': deviceID,
              'logged': false,
              'timestamp': time.toString(),
              'lastTime': '0h 0min',
              'locations': [],
              'isForeman': isForeman
            });

            await FirebaseFirestore.instance.collection('admin').doc(companies[0].id).update({
              'users': userList,
              'devices': deviceList
            });

            ToastBar(color: Colors.green,text: 'Device Registered!').show();
              Navigator.of(context).pushAndRemoveUntil(
                  CupertinoPageRoute(builder: (context) => DashBoard(
                    name: fname.text+' '+lname.text,
                    deviceID: deviceID,
                    id: id.text,
                    companyName: companies[0]['fname']+' '+companies[0]['lname'],
                    code: code.text,
                    email: email.text,
                    isLogged: false,
                    lastTime: '0h 0min',
                    companyEmail: companyEmail,)), (Route<dynamic> route) => false);
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
            Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (context) => DashBoard(
                  deviceID: deviceID,
                  companyName: companies[0]['fname']+' '+companies[0]['lname'],
                  id: users[0]['id'],
                  name: users[0]['fname']+' '+users[0]['lname'],
                  code: companies[0]['code'],
                  email: users[0]['email'],
                  isLogged: users[0]['logged'],
                  lastTime: users[0]['lastTime'],
                  companyEmail: companies[0]['email'],
                )), (Route<dynamic> route) => false);
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

                InputField(hint: 'First Name',controller: fname,),
                InputField(hint: 'Last Name',controller: lname,),
                InputField(hint: 'Email',type: TextInputType.emailAddress,controller: email,),
                InputField(hint: 'ID Number',controller: id,),
                InputField(hint: 'Company Code',controller: code,),

                Padding(
                  padding: EdgeInsets.all(ScreenUtil().setHeight(40)),
                  child: Theme(
                    data: ThemeData(
                      unselectedWidgetColor: Colors.white
                    ),
                    child: CheckboxListTile(
                      value: isForeman,
                      onChanged: (x){
                        setState(() {
                          isForeman = x;
                        });
                      },
                      checkColor: Colors.black,
                      activeColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: CustomText(text: 'Are you a Foreman?',),
                    ),
                  ),
                ),
              
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
                  child: Button(text: 'Go',borderRadius: 10,color: Constants.kButtonBlue,onclick: ()=>registerDevice(),),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
