import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:skytech/screens/admin/settings.dart';
import 'package:skytech/screens/admin/user-analytics.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/toast.dart';

class AdminDashboard extends StatefulWidget {

  final String fname;
  final String lname;
  final String code;
  final String email;

  const AdminDashboard({Key key, this.fname, this.code, this.lname, this.email}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String location;
  String sorting;
  List<DropdownMenuItem<String>> workingSiteList = [];
  int totalMins = 0;
  String totalHours = '0';

  String durationToString(int minutes) {
    var d = Duration(minutes:minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  getWorkingSites() async {
    var sub = await FirebaseFirestore.instance.collection('admin').doc(widget.email).collection('sites').get();
    var workingSites = sub.docs;
    location = "All";
    workingSiteList.add(
        DropdownMenuItem(child: CustomText(text:"All",color: Colors.black,),value: "All",)
    );
    for(int i=0;i<workingSites.length;i++){
      totalMins += workingSites[i]['total'];
      setState(() {
        workingSiteList.add(
          DropdownMenuItem(child: CustomText(text:workingSites[i]['site'],color: Colors.black,),value: workingSites[i]['site'],),
        );
      });
    }
    setState(() {
      totalHours = durationToString(totalMins);
    });
  }

  exportCsv() async {

    ///initializing progress dialog
    ProgressDialog pr = ProgressDialog(context);
    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        message: 'Please wait...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: Center(child: CircularProgressIndicator()),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: ScreenUtil().setSp(35), fontWeight: FontWeight.bold)
    );

    ///showLoadingDialog
    pr.show();

    ///getting Dates
    // DateTime time = await NTP.now();
    // DateTime now = time.toUtc().subtract(Duration(hours: 7));
    DateTime now = DateTime.now();
    var start = DateFormat('MM/dd/yyyy').format(now.subtract(Duration(days: now.weekday -1)));
    var end = DateFormat('MM/dd/yyyy').format(now.add(Duration(days: DateTime.daysPerWeek - now.weekday)));
    print("Start "+start.toString());
    print("End "+end.toString());

    try{
      ///get local storage path
      Directory directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();
      String path = directory.absolute.path;
      String reportName = 'report_' + DateFormat('yyyy_MM_dd').format(now.subtract(Duration(days: now.weekday -1)));
      String finalPath = "$path/$reportName.csv";
      print(finalPath);
      File csvFile = await File(finalPath).create();

      List<List<dynamic>> rows = List<List<dynamic>>();

      ///add Headers to the csv
      rows.add(['ID','Last Name','First Name','Date','In','Out','Lat','Long','Location','Notes']);

      ///get All users
      var namesSub = await FirebaseFirestore.instance.collection('user').where('code', isEqualTo: widget.code).get();
      var names = namesSub.docs;

      if(names.isNotEmpty){
        ///looping each users for name and ids
        for(int i=0;i<names.length;i++) {
          ///get firstName and lastName
          String fname = names[i]['fname'];
          String lname = names[i]['lname'];
          String id = names[i] ['id'];

          ///get each log of a single user
          var singleLogSub = await FirebaseFirestore.instance.collection('logs').doc(names[i].id).collection('logs').where('date', isGreaterThanOrEqualTo: start).where('date', isLessThanOrEqualTo: end).get();
          var singleSub = singleLogSub.docs;

          if(singleSub.isNotEmpty){
            ///loop each log
            singleSub.forEach((log) {
              List<dynamic> row = List<dynamic>();
              row.add(id);
              row.add(lname);
              row.add(fname);
              row.add(log['date']);
              row.add(log['login']);
              row.add(log['logout']);
              row.add(log['loginLat']);
              row.add(log['loginLong']);
              row.add(log['location']);
              row.add(log['notes']);
              rows.add(row);
            });

          }

        }
        print(rows);
        String csv = ListToCsvConverter().convert(rows);
        csvFile.writeAsString(csv);
        pr.hide();
        ToastBar(text: 'Report Generated Successfully at $finalPath',color: Colors.green).show();
      }
    }
    catch(e){
      pr.hide();
      print("error "+e.toString());
    }


  }

  List<DocumentSnapshot> profiles;
  StreamSubscription<QuerySnapshot> subscription;

  filterData(){
    final CollectionReference collectionReference  = FirebaseFirestore.instance.collection("user");
    setState(() {
          if(location=="All"&&sorting=="name"){
                getData(collectionReference.where('code',isEqualTo: widget.code).orderBy('logged', descending: true).orderBy('fname'));
          }
          else if(location=="All"&&sorting=="date"){
            getData(collectionReference.where('code',isEqualTo: widget.code).orderBy('logged', descending: true).orderBy('timestamp',descending: true));
          }
          else if(location!="All"&&sorting=="name"){
            getData(collectionReference.where('code',isEqualTo: widget.code).where('locations',arrayContains: location).orderBy('logged', descending: true).orderBy('fname'));
          }
          else if(location!="All"&&sorting=="date"){
            getData(collectionReference.where('code',isEqualTo: widget.code).where('locations',arrayContains: location).orderBy('logged', descending: true).orderBy('timestamp',descending: true));
          }
    });
  }

  getData(var q) async{
    if(subscription!=null){
      subscription.cancel();
    }
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
    getData(FirebaseFirestore.instance.collection("user").where('code',isEqualTo: widget.code).orderBy('logged', descending: true).orderBy('fname'));

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
        title: CustomText(text: 'Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: (){
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => SettingsScreen(code: widget.code,email: widget.email,)),
            );
          })
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ScreenUtil().setHeight(20),),


          ///name and export button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(400),
                child: Padding(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(40)),
                  child: CustomText(text: widget.fname+' '+widget.lname,size: ScreenUtil().setSp(40),align: TextAlign.start,isBold: false,color: Color(0xffE6D5B8),),
                ),
              ),
              ///exportButton
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
                  child: Button(color: Colors.white,text: 'Export CSV',onclick: ()=>exportCsv(),textColor: Colors.green,),
                ),
              )
            ],
          ),
          SizedBox(height: ScreenUtil().setHeight(30),),


          ///siteSelector and total hours
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
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
                ///totalHours
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xff99A8B2),
                      border: Border.all(color: Colors.white,width: 3)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
                    child: Column(
                      children: [
                        CustomText(text: '$totalHours H',size: ScreenUtil().setSp(35),color: Colors.black,),
                        CustomText(text: 'Total Working Time',isBold: false,size: ScreenUtil().setSp(25),color: Colors.black,),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(30),),
          ///profiles
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
                          CustomText(text: 'Profiles',size: ScreenUtil().setSp(40),),
                          Container(
                            height: ScreenUtil().setHeight(70),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.black,
                                border: Border.all(color: Colors.white,width: 3)
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                              child: DropdownButton(
                                underline: Divider(color: Colors.black,height: 0,thickness: 0,),
                                dropdownColor: Colors.black,

                                items: <DropdownMenuItem> [
                                  DropdownMenuItem(child: CustomText(text: "Sort by name",),value: "name",),
                                  DropdownMenuItem(child: CustomText(text: "Sort by date",),value: "date",),
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
                              String name = profiles[i]['fname']+' '+profiles[i]['lname'];
                              String email = profiles[i]['email'];
                              bool logged = profiles[i]['logged'];
                              return Padding(
                                padding:  EdgeInsets.only(bottom: ScreenUtil().setHeight(25)),
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(builder: (context) => UserAnalytics(name: name,email: email,workSite: location,totalMins: totalMins,adminEmail: widget.email,)),
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).accentColor,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Colors.black,width: 3)
                                    ),
                                    child: Padding(
                                      padding:  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          logged?CircleAvatar(
                                            radius: 7,
                                            backgroundColor: Colors.white,
                                            child: CircleAvatar(
                                              radius: 5,
                                              backgroundColor: Colors.green,
                                            ),
                                          ):SizedBox.shrink(),
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
