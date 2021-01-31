import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom-text.dart';

class ImageButton extends StatelessWidget {

  final onclick;
  final String text;
  final String image;
  final Color color;
  final Color textColor;
  final double borderRadius;


  const ImageButton({Key key, this.onclick, this.text, this.color: Colors.black, this.borderRadius=30, this.textColor=Colors.white, this.image,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        onPressed: onclick,
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: color,
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
                height: ScreenUtil().setWidth(45),
                child: Image.asset('images/$image')),
            SizedBox(width: ScreenUtil().setWidth(15),),
            CustomText(text: text,size: 14,color: textColor,),
          ],
        ),
      ),
    );
  }
}