import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';

class UserAnalytics extends StatelessWidget {

  popUpCard(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: CustomText(text: 'Device ID',align: TextAlign.center,color: Colors.black,),
          content: Container(
            height: ScreenUtil().setHeight(290),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color(0xff99A8B2),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                    child: CustomText(text: 'abcde-fghij-klmno-pqrst-uvwxyz',color: Colors.white,size: ScreenUtil().setSp(30),),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.all(ScreenUtil().setHeight(40)),
                  child: Button(text: 'Remove ID',color: Colors.red,onclick: (){
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

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'User Analytics'),
        actions: [
          IconButton(icon: Icon(Icons.phonelink_setup), onPressed: ()=>popUpCard(context))
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
            child: Row(
              children: [
                Icon(Icons.account_circle_outlined,color: Colors.white,size: 35,),
                SizedBox(width: ScreenUtil().setWidth(20),),
                CustomText(text: 'Dulaj Nadawa',size: ScreenUtil().setSp(50),),
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(left: ScreenUtil().setWidth(40)),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40)
              ),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setHeight(25)),
                child: CustomText(text: 'Logged In',color: Colors.green,size: ScreenUtil().setSp(30),),
              ),
            ),
          ),

          Padding(
            padding:  EdgeInsets.all(ScreenUtil().setHeight(40)),
            child: Button(text: 'Logout User',color: Colors.red,onclick: (){}),
          ),

          Expanded(
            child: Padding(
              padding:  EdgeInsets.all(ScreenUtil().setHeight(30)),
              child: ListView(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xff99A8B2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding:  EdgeInsets.all(ScreenUtil().setHeight(25)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today,size: 25,),
                              SizedBox(width: ScreenUtil().setWidth(20),),
                              CustomText(text: '12/31/2020',size: ScreenUtil().setSp(35),color: Colors.black,),
                            ],
                          ),
                          SizedBox(height: ScreenUtil().setHeight(20),),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xffE6D5B8),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
                                            border: Border.all(color: Colors.white,width: 3)
                                        ),
                                        child: Padding(
                                          padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
                                          child: Row(
                                            children: [
                                              CustomText(text: 'Login:-',size: ScreenUtil().setSp(35),color: Colors.black,),
                                              SizedBox(width: ScreenUtil().setWidth(10),),
                                              Expanded(
                                                child: TextField(
                                                  cursorColor: Colors.black,
                                                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(35)),
                                                  decoration: InputDecoration(
                                                    hintText: '00:00',
                                                    enabledBorder:InputBorder.none,
                                                    focusedBorder: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(10)),
                                          border: Border.all(color: Colors.white,width: 3)
                                        ),
                                        child: Padding(
                                          padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
                                          child: Row(
                                            children: [
                                              CustomText(text: 'Logout:-',size: ScreenUtil().setSp(35),color: Colors.black,),
                                              SizedBox(width: ScreenUtil().setWidth(10),),
                                              Expanded(
                                                child: TextField(
                                                  cursorColor: Colors.black,
                                                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(35)),
                                                  decoration: InputDecoration(
                                                    hintText: '00:00',
                                                    enabledBorder:InputBorder.none,
                                                    focusedBorder: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                                  child: Row(
                                    children: [
                                      CustomText(text: 'Latitude :- ',size: ScreenUtil().setSp(35),color: Colors.black,),
                                      SizedBox(width: ScreenUtil().setWidth(10),),
                                      Expanded(
                                        child: TextField(
                                          cursorColor: Colors.black,
                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(35)),
                                          decoration: InputDecoration(
                                            hintText: '6.541234',
                                            enabledBorder:InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                                  child: Row(
                                    children: [
                                      CustomText(text: 'Longitude :- ',size: ScreenUtil().setSp(35),color: Colors.black,),
                                      SizedBox(width: ScreenUtil().setWidth(10),),
                                      Expanded(
                                        child: TextField(
                                          cursorColor: Colors.black,
                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(35)),
                                          decoration: InputDecoration(
                                            hintText: '6.541234',
                                            enabledBorder:InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
