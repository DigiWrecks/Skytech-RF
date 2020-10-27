import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';


class Settings extends StatelessWidget {

  popUpCard(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: CustomText(text: 'Add new Location',align: TextAlign.center,color: Colors.black,),
          content: Container(
            height: ScreenUtil().setHeight(280),
            child: Column(
              children: [
                TextField(
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: 'Enter New Location',
                    enabledBorder:UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 5),
                    ),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.all(ScreenUtil().setHeight(40)),
                  child: Button(text: 'Add',color: Colors.red,onclick: (){
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
        title: CustomText(text: 'Settings'),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>popUpCard(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.white,
      ),

      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(35)),
              child: CustomText(text: 'Company Code',size: ScreenUtil().setSp(35),),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                child: CustomText(text: 'company_code',color: Colors.black,size: ScreenUtil().setSp(30),),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(35)),
              child: CustomText(text: 'Work Sites',size: ScreenUtil().setSp(35),),
            ),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding:  EdgeInsets.only(bottom: ScreenUtil().setHeight(25)),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                            child: CustomText(text: 'Kokmaduwa',color: Colors.black,size: ScreenUtil().setSp(30),),
                          ),
                          IconButton(icon: Icon(Icons.delete), onPressed: (){print("delete pressed");})
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(bottom: ScreenUtil().setHeight(25)),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                            child: CustomText(text: 'Kokmaduwa',color: Colors.black,size: ScreenUtil().setSp(30),),
                          ),
                          IconButton(icon: Icon(Icons.delete), onPressed: (){print("delete pressed");})
                        ],
                      ),
                    ),
                  ),


                ],
              ),
            )
          ],
        ),
      ),


    );
  }
}
