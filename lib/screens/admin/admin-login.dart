import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:skytech/screens/admin/admin-register.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/inputfield.dart';

class AdminLogin extends StatefulWidget {
  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

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

                CustomText(text: 'Log In',size: ScreenUtil().setSp(60)),

                InputField(hint: 'Email',type: TextInputType.emailAddress,controller: email,),
                InputField(hint: 'Password',ispassword: true,controller: password,),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
                  child: Button(text: 'Login',onclick: (){},),
                ),

                GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => AdminRegister()),
                      );
                    },
                    child: CustomText(text: "Don't have an account? Sign up",size: ScreenUtil().setSp(30),)),



              ],
            ),
          ),
        ),
      ),
    );
  }
}
