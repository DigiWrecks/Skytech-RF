import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/inputfield.dart';

class RegisterDevice extends StatefulWidget {
  @override
  _RegisterDeviceState createState() => _RegisterDeviceState();
}

class _RegisterDeviceState extends State<RegisterDevice> {

  TextEditingController name = TextEditingController();
  TextEditingController code = TextEditingController();
  TextEditingController email = TextEditingController();
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
                  child: Button(text: 'Register',onclick: (){},),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
