import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:skytech/screens/admin/settings.dart';
import 'package:skytech/widgets/custom-text.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'Profiles'),
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: (){
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => Settings()),
            );
          })
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
              child: CustomText(text: 'Hello,',size: ScreenUtil().setSp(45),),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
              child: CustomText(text: 'Dulaj Nadawa',size: ScreenUtil().setSp(70),align: TextAlign.start,),
            ),
            SizedBox(height: ScreenUtil().setHeight(30),),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                  child: CustomText(text: 'Location - Site ID',color: Colors.black,size: ScreenUtil().setSp(30),),
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(30),),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color(0xff99A8B2),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                  child: Column(
                    children: [
                      CustomText(text: 'Latitude',color: Colors.black,size: ScreenUtil().setSp(35),),
                      SizedBox(height: ScreenUtil().setHeight(20),),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                            child: CustomText(text: 'lat',color: Colors.black,size: ScreenUtil().setSp(30),),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(20),),
                      CustomText(text: 'Longitude',color: Colors.black,size: ScreenUtil().setSp(35),),
                      SizedBox(height: ScreenUtil().setHeight(20),),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                            child: CustomText(text: 'long',color: Colors.black,size: ScreenUtil().setSp(30),),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(20),),
                    ],
                  ),
                ),
              ),
            ),



          ],
        ),
      ),

    );
  }
}
