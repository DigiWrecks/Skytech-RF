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
    );
  }
}
