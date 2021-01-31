import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:skytech/constants.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/toast.dart';

class Comments extends StatefulWidget {
  final String location;
  final String date;
  final String name;
  final String email;
  const Comments({Key key, this.location, this.date, this.name, this.email}) : super(key: key);

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  TextEditingController comments = TextEditingController();
  String timestamp;

  getTimestamp() async {
    var sub = await FirebaseFirestore.instance.collection('user').where('email',isEqualTo: widget.email).get();
    var details = sub.docs;
    setState(() {
      timestamp = details[0]['timestamp'];
    });
  }

  getComments()async{
    await getTimestamp();
    var sub = await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').where('timestamp',isEqualTo: timestamp).get();
    var details = sub.docs;
    setState(() {
      comments.text = details[0]['notes'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'Comments'),
      ),
      body: Padding(
        padding: EdgeInsets.all(ScreenUtil().setHeight(40)),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding:  EdgeInsets.all(ScreenUtil().setHeight(25)),
            child: Column(
              children: [

                ///location
                CustomText(text: widget.location,size: ScreenUtil().setSp(35),),
                SizedBox(height: ScreenUtil().setHeight(20),),

                ///name and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ///location
                    CustomText(text: widget.name,size: ScreenUtil().setSp(30)),
                    ///date
                    CustomText(text: widget.date,size: ScreenUtil().setSp(30)),
                  ],
                ),
                SizedBox(height: ScreenUtil().setHeight(30),),


                ///comment box
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white
                    ),
                    child: TextField(
                      maxLines: null,
                      controller: comments,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        hintText: 'Type your comment here',
                      ),
                    ),
                  ),
                ),


                ///save
                SizedBox(height: ScreenUtil().setHeight(30),),
                Button(
                  text: 'Save',
                  color: Constants.kButtonBlue,
                  borderRadius: 10,
                  onclick: () async {
                    await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(timestamp).update({
                      'notes': comments.text
                    });
                    ToastBar(text: 'Comment Added',color: Colors.green).show();
                    Navigator.pop(context);
                  },
                ),

                

              ],
            ),
          ),
        ),
      ),
    );
  }
}
