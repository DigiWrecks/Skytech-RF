import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/inputfield.dart';
import 'package:skytech/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminRegister extends StatefulWidget {
  @override
  _AdminRegisterState createState() => _AdminRegisterState();
}

class _AdminRegisterState extends State<AdminRegister> {

  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController code = TextEditingController();

  Future sendEmail() async{
    if (await canLaunch("mailto:accesscode@irfanet.net?subject=Requesting Company Code&body=I want a company code!")) {
      await launch("mailto:accesscode@irfanet.net?subject=Requesting Company Code&body=I want a company code!");
    } else {
      ToastBar(text: 'Error Launching Application!',color: Colors.red).show();
      throw 'Could not launch';
    }
  }

  signUp() async {
    await Firebase.initializeApp();
    if(email.text!='' && password.text!='' && name.text!=''&& code.text!=''){
      ToastBar(color: Colors.orange,text: 'Please wait...').show();

      var sub = await FirebaseFirestore.instance.collection('codes').where('code',isEqualTo: code.text).get();
      var codes = sub.docs;
      if(codes.isNotEmpty){
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email.text,
              password: password.text
          );

          try{
            await FirebaseFirestore.instance.collection('admin').doc(email.text).set({
              'name': name.text,
              'email': email.text,
              'code': code.text,
              'sites': [],
              'users': [],
              'devices': []
            });

            name.clear();
            email.clear();
            password.clear();
            code.clear();

            ToastBar(color: Colors.green,text: 'Signed up successfully!').show();

            Navigator.pop(context);
          }
          catch(e){
            ToastBar(color: Colors.red,text: 'Something went wrong!').show();
            print("error is"+e.toString());
          }

        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            ToastBar(color: Colors.red,text: 'Password is too weak!').show();
          } else if (e.code == 'email-already-in-use') {
            ToastBar(color: Colors.red,text: 'Account Already Exists!').show();
          }
        } catch (e) {
          ToastBar(color: Colors.red,text: 'Something went wrong!').show();
          print("error is"+e.toString());
        }
      }
      else{
        ToastBar(color: Colors.red,text: 'Company Code doesn\'t exists!').show();
      }


    }else{
      ToastBar(color: Colors.red,text: 'Please Fill all the Fields!').show();
    }
  }

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

                CustomText(text: 'Sign Up',size: ScreenUtil().setSp(60)),

                InputField(hint: 'Name',controller: name,),
                InputField(hint: 'Email',type: TextInputType.emailAddress,controller: email,),
                InputField(hint: 'Password',ispassword: true,controller: password,),
                InputField(hint: 'Company Code',controller: code,),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
                  child: Button(text: 'Sign Up',onclick: ()=>signUp(),),
                ),

                Center(
                  child: GestureDetector(
                      onTap: ()=>sendEmail(),
                      child: CustomText(text: "Request a company code",size: ScreenUtil().setSp(30),)),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
