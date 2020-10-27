import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/inputfield.dart';
import 'package:skytech/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminRegister extends StatefulWidget {
  @override
  _AdminRegisterState createState() => _AdminRegisterState();
}

class _AdminRegisterState extends State<AdminRegister> {

  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController code = TextEditingController();

  Future sendEmail() async{
    if (await canLaunch("mailto:accesscode@irfanet.net?subject=Requesting Company Code&body=I want a company code!")) {
      await launch("mailto:accesscode@irfanet.net?subject=Requesting Company Code&body=I want a company code!");
    } else {
      ToastBar(text: 'Error Launching Application!',color: Colors.red).show();
      throw 'Could not launch';
    }
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

                CustomText(text: 'Sign Up',size: ScreenUtil().setSp(60)),

                InputField(hint: 'Name',controller: name,),
                InputField(hint: 'Email',type: TextInputType.emailAddress,controller: email,),
                InputField(hint: 'Password',ispassword: true,controller: password,),
                InputField(hint: 'Company Code',controller: code,),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
                  child: Button(text: 'Sign Up',onclick: (){},),
                ),

                Center(
                  child: GestureDetector(
                      onTap: ()=>sendEmail(),
                      child: CustomText(text: "Request a company code",size: ScreenUtil().setSp(30),)),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
