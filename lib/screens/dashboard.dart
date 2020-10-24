import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skytech/widgets/custom-text.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String lat = "N/A";
  String long = "N/A";

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'Dashboard'),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ScreenUtil().setHeight(50),),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: ScreenUtil().setHeight(100),
                width: ScreenUtil().setWidth(330),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(10))
                ),
                child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.calendar_today,size: 27,),
                        SizedBox(width: ScreenUtil().setWidth(20),),
                        CustomText(text: "23/10/2020",size: ScreenUtil().setSp(40),color: Colors.black,),
                      ],
                    )
                ),
              ),
            ),
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
                            child: CustomText(text: lat,color: Colors.black,size: ScreenUtil().setSp(30),),
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
                            child: CustomText(text: long,color: Colors.black,size: ScreenUtil().setSp(30),),
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
