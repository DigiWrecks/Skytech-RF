import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:skytech/screens/admin/settings.dart';
import 'package:skytech/screens/admin/user-analytics.dart';
import 'package:skytech/widgets/custom-text.dart';

class AdminDashboard extends StatefulWidget {

  final String name;
  final String code;

  const AdminDashboard({Key key, this.name, this.code}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String location;
  String sorting;
  List<DropdownMenuItem<String>> workingSiteList = [];

  getWorkingSites() async {
    await Firebase.initializeApp();
    var sub = await FirebaseFirestore.instance.collection('admin').where('code',isEqualTo: widget.code).get();
    var workingSites = sub.docs;
    location = "All";
    workingSiteList.add(
        DropdownMenuItem(child: CustomText(text:"All",color: Colors.black,),value: "All",)
    );
    for(int i=0;i<workingSites[0]['sites'].length;i++){
      setState(() {
        workingSiteList.add(
          DropdownMenuItem(child: CustomText(text:workingSites[0]['sites'][i],color: Colors.black,),value: workingSites[0]['sites'][i],),
        );
      });
    }
  }


  List<DocumentSnapshot> profiles;
  StreamSubscription<QuerySnapshot> subscription;

  filterData(){
    final CollectionReference collectionReference  = FirebaseFirestore.instance.collection("user");
    setState(() {
          if(location=="All"&&sorting=="name"){
                getData(collectionReference.where('code',isEqualTo: widget.code).orderBy('name',descending: true));
          }
          else if(location=="All"&&sorting=="date"){
            getData(collectionReference.where('code',isEqualTo: widget.code).orderBy('timestamp',descending: true));
          }
          else if(location!="All"&&sorting=="name"){
            getData(collectionReference.where('code',isEqualTo: widget.code).where('locations',arrayContains: location).orderBy('name',descending: true));
          }
          else if(location!="All"&&sorting=="date"){
            getData(collectionReference.where('code',isEqualTo: widget.code).where('locations',arrayContains: location).orderBy('timestamp',descending: true));
          }
    });
  }

  getData(var q) async{
    subscription = q.snapshots().listen((datasnapshot){
      setState(() {
        profiles = datasnapshot.docs;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWorkingSites();
    sorting = "name";
    getData(FirebaseFirestore.instance.collection("user").where('code',isEqualTo: widget.code).orderBy('name',descending: true));

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'Profiles'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: (){
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => SettingsScreen(code: widget.code,)),
            );
          })
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ScreenUtil().setHeight(20),),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
            child: CustomText(text: widget.name,size: ScreenUtil().setSp(70),align: TextAlign.start,),
          ),
          SizedBox(height: ScreenUtil().setHeight(30),),
          Center(
            child: Container(
              height: ScreenUtil().setHeight(90),
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
                      filterData();
                    });
                  },
                  value: location,
                ),
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(30),),
          Expanded(
            child: Padding(
              padding:  EdgeInsets.all(ScreenUtil().setWidth(40)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(text: 'Profiles',color: Colors.black,size: ScreenUtil().setSp(40),),
                          Container(
                            height: ScreenUtil().setHeight(70),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.white,
                                border: Border.all(color: Colors.black,width: 3)
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                              child: DropdownButton(
                                underline: Divider(color: Colors.white,height: 0,thickness: 0,),
                                items: <DropdownMenuItem> [
                                  DropdownMenuItem(child: CustomText(text: "Sort by name",color: Colors.black,),value: "name",),
                                  DropdownMenuItem(child: CustomText(text: "Sort by date",color: Colors.black,),value: "date",),
                                ],
                                onChanged:(newValue){
                                  setState(() {
                                    sorting = newValue;
                                    filterData();
                                  });
                                },
                                value: sorting,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(40),),
                      Expanded(
                        child: Padding(
                          padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
                          child: profiles!=null?ListView.builder(
                            itemCount: profiles.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context,i){
                              String name = profiles[i]['name'];
                              String email = profiles[i]['email'];
                              return Padding(
                                padding:  EdgeInsets.only(bottom: ScreenUtil().setHeight(25)),
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(builder: (context) => UserAnalytics(name: name,email: email,workSite: location,)),
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: Color(0xffE6D5B8),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Colors.black,width: 3)
                                    ),
                                    child: Padding(
                                      padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                                              child: CustomText(text: name,color: Colors.black,size: ScreenUtil().setSp(35),),
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ):Center(child: CircularProgressIndicator(),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),



        ],
      ),

    );
  }
}
