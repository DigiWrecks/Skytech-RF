import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'custom-text.dart';

class Button extends StatelessWidget {

  final onclick;
  final String text;
  final Color color;
  final Color textColor;
  final bool social;
  final double borderRadius;

  const Button({Key key, this.onclick, this.text, this.color: Colors.black, this.social=false, this.borderRadius=30, this.textColor=Colors.white,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        onPressed: () async {
            Vibrate.feedback(FeedbackType.medium);
            onclick();
        },
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: color,
        padding: EdgeInsets.all(10),
        child: CustomText(text: text,size: 18,color: textColor,),
      ),
    );
  }
}