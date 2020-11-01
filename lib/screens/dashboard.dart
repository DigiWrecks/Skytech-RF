import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:skytech/screens/log.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/toast.dart';


class DashBoard extends StatefulWidget {

  final String name;
  final String id;
  final String companyName;
  final String deviceID;
  final String code;
  final String email;
  final bool isLogged;
  final String lastTime;


  const DashBoard({Key key, this.name, this.id, this.companyName, this.deviceID, this.code, this.email, this.isLogged=true, this.lastTime}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String lat = "N/A";
  String long = "N/A";
  String date = "N/A";
  String location;
  List<DropdownMenuItem<String>> workingSiteList = [];
  bool logged;
  String lastTime;
  double distance;

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() {
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });
  }

  getDate() async {
    DateTime now = await NTP.now();
    setState(() {
      date = DateFormat('MM/dd/yyyy').format(now.toUtc().subtract(Duration(hours: 7)));
    });
  }

  getWorkingSites() async {
    await Firebase.initializeApp();
    var sub = await FirebaseFirestore.instance.collection('admin').where('code',isEqualTo: widget.code).get();
    var workingSites = sub.docs;
    location = workingSites[0]['sites'][0];
    for(int i=0;i<workingSites[0]['sites'].length;i++){
      setState(() {
        workingSiteList.add(
          DropdownMenuItem(child: CustomText(text:workingSites[0]['sites'][i],color: Colors.black,),value: workingSites[0]['sites'][i],),
        );
      });
    }
  }

  calculateDistance({double sLat,double sLong}) async {
    getLocation();
    print(sLat.toString()+" "+sLong.toString());
    distance = Geolocator.distanceBetween(sLat, sLong, double.parse(lat), double.parse(long));
  }

  onLoginPressed() async {
    ToastBar(color: Colors.orange,text: 'Please wait...').show();
    try{
      DateTime now = await NTP.now();
      String time = DateFormat('hh:mm a').format(now.toUtc().subtract(Duration(hours: 7)));
      String timestamp = now.toUtc().subtract(Duration(hours: 7)).toString();

      var sub = await FirebaseFirestore.instance.collection('user').where('email',isEqualTo: widget.email).get();
      var details = sub.docs;

      List locationList = details[0]['locations'];
      if(!locationList.contains(location)){
        locationList.add(location);
      }

      await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(timestamp).set({
            'timestamp': timestamp,
            'lat': lat,
            'long': long,
            'location': location,
            'date': date,
            'login': time,
            'logout': 'n/a',
            'worked': 'n/a'
      });

      await FirebaseFirestore.instance.collection('user').doc(widget.email).update({
        'logged': true,
        'timestamp': timestamp,
        'locations': locationList
      });

      setState(() {
        logged = true;
      });
      ToastBar(color: Colors.green,text: 'Logged in!').show();
    }
    catch(e){
      ToastBar(color: Colors.red,text: 'Something went wrong!').show();
    }
  }

  onLogoutPressed() async {
    ToastBar(color: Colors.orange,text: 'Please wait...').show();
    try{

      var sub = await FirebaseFirestore.instance.collection('user').where('email',isEqualTo: widget.email).get();
      var details = sub.docs;

      String timestamp = details[0]['timestamp'];

      var sub2 = await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').where('timestamp', isEqualTo: timestamp).get();
      var locations = sub2.docs;
      calculateDistance(sLat: double.parse(locations[0]['lat']),sLong: double.parse(locations[0]['long']));
     print('distance is'+distance.toString());

     if(distance<76){
       DateTime now = await NTP.now();
       String time = DateFormat('hh:mm a').format(now.toUtc().subtract(Duration(hours: 7)));
       var durInMins =  now.toUtc().subtract(Duration(hours: 7)).difference(DateTime.parse(timestamp)).inMinutes;
       var durInHours =  now.toUtc().subtract(Duration(hours: 7)).difference(DateTime.parse(timestamp)).inHours;
       int mins = durInMins - durInHours*60;
       // print(durInHours.toString()+" h "+mins.toString()+" min");

       await FirebaseFirestore.instance.collection('logs').doc(widget.email).collection('logs').doc(timestamp).update({
         'logout': time,
         'worked': durInHours.toString()+" h "+mins.toString()+" min"
       });

       await FirebaseFirestore.instance.collection('user').doc(widget.email).update({
         'logged': false,
         'lastTime': durInHours.toString()+" h "+mins.toString()+" min"
       });

       setState(() {
         logged = false;
         lastTime = durInHours.toString()+" h "+mins.toString()+" min";
       });
       ToastBar(color: Colors.green,text: 'Logged out!').show();
     }
     else{
       ToastBar(color: Colors.red,text: 'You must within the range of 250ft from your logged in location!').show();
     }

    }
    catch(e){
      ToastBar(color: Colors.red,text: "Something went wrong!").show();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
    getDate();
    getWorkingSites();
    logged = widget.isLogged;
    lastTime = widget.lastTime;
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.assessment_sharp), onPressed: (){
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => Log(email: widget.email,)),
            );
          })
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ScreenUtil().setHeight(30),),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: ScreenUtil().setHeight(80),
                width: ScreenUtil().setWidth(260),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(10))
                ),
                child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.calendar_today,size: 20,),
                        SizedBox(width: ScreenUtil().setWidth(20),),
                        CustomText(text: date,size: ScreenUtil().setSp(30),color: Colors.black,),
                      ],
                    )
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(10),),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
              child: CustomText(text: widget.name,size: ScreenUtil().setSp(50),align: TextAlign.start,),
            ),
            SizedBox(height: ScreenUtil().setHeight(10),),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
              child: CustomText(text: 'ID : ${widget.id}',size: ScreenUtil().setSp(30),),
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
                      CustomText(text: 'Latitude',color: Colors.black,size: ScreenUtil().setSp(30),),
                      SizedBox(height: ScreenUtil().setHeight(15),),
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
                            child: CustomText(text: lat,color: Colors.black,size: ScreenUtil().setSp(28),),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15),),
                      CustomText(text: 'Longitude',color: Colors.black,size: ScreenUtil().setSp(30),),
                      SizedBox(height: ScreenUtil().setHeight(15),),
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
                            child: CustomText(text: long,color: Colors.black,size: ScreenUtil().setSp(28),),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15),),
                      CustomText(text: 'Company Name',color: Colors.black,size: ScreenUtil().setSp(30),),
                      SizedBox(height: ScreenUtil().setHeight(15),),
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
                            child: CustomText(text: widget.companyName,color: Colors.black,size: ScreenUtil().setSp(28),),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15),),
                      CustomText(text: 'Device ID',color: Colors.black,size: ScreenUtil().setSp(30),),
                      SizedBox(height: ScreenUtil().setHeight(15),),
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
                            child: CustomText(text: widget.deviceID,color: Colors.black,size: ScreenUtil().setSp(28),),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15),),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: ScreenUtil().setHeight(30),),

            Visibility(
              visible: !logged,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xff99A8B2),
                    border: Border.all(color: Colors.white,width: 3)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
                    child: DropdownButton(
                      underline: Divider(color: Color(0xff99A8B2),height: 0,thickness: 0,),
                      items: workingSiteList,
                      onChanged:(newValue){
                        setState(() {
                          location = newValue;
                        });
                      },
                      value: location,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(40),),
            Center(
              child: GestureDetector(
                onTap: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        content: CustomText(text: 'Are you sure you want to ${!logged?'log in':'log out'}?',color: Colors.black,),
                        actions: [
                          FlatButton(onPressed: (){
                            !logged?onLoginPressed():onLogoutPressed();
                            Navigator.pop(context);
                            }, child: CustomText(text: 'Yes',color: Colors.black,)),
                          FlatButton(onPressed: () async {
                            Navigator.pop(context);
                          }, child: CustomText(text: 'No',color: Colors.black,)),
                        ],
                      );
                    }
                  );
                },
                child: Container(
                  width: ScreenUtil().setWidth(400),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: !logged?Colors.green:Colors.red
                  ),
                  child: Padding(
                    padding:  EdgeInsets.all(ScreenUtil().setSp(40)),
                    child: CustomText(text: !logged?'Login':'Logout',size: ScreenUtil().setSp(70),),
                  ),
                ),
              ),
            ),

            Visibility(
              visible: !logged,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  child: CustomText(text: 'Last logged time - $lastTime',size: ScreenUtil().setSp(35),),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
