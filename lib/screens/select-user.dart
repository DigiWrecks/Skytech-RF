import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:skytech/screens/admin/admin-login.dart';
import 'package:skytech/screens/register-device.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';

class SelectUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:  EdgeInsets.all(ScreenUtil().setHeight(80)),
              child: Image.asset('images/logo.png'),
            ),
            SizedBox(height: ScreenUtil().setHeight(50),),
            Padding(
              padding:  EdgeInsets.all(ScreenUtil().setHeight(30)),
              child: CustomText(text: 'Profile Not Found',size: ScreenUtil().setSp(50),),
            ),
            SizedBox(height: ScreenUtil().setHeight(50),),
            Padding(
              padding:  EdgeInsets.all(ScreenUtil().setHeight(30)),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xff9CA7B3),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        border: Border.all(color: Colors.white,width: 3)
                      ),
                      child: Padding(
                        padding:  EdgeInsets.all(ScreenUtil().setHeight(40)),
                        child: CustomText(text: 'Who you are?',size: ScreenUtil().setSp(40),),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(100),),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(50)),
                      child: Button(text: 'Admin Login',color: Colors.white,textColor: Colors.black,onclick: (){
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => AdminLogin()),
                        );
                      },),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(50),),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setHeight(50)),
                      child: Button(text: 'Register Device',color: Colors.white,textColor: Colors.black,onclick: (){
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => RegisterDevice()),
                        );
                      },),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(100),),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
