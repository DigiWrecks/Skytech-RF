import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skytech/constants.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';


class Locations extends StatefulWidget {
  final String email;

  const Locations({Key key, this.email}) : super(key: key);
  @override
  _LocationsState createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {
  List locations;
  List<String> suggestionList = [];
  bool isLoading = false;

  getLocations(String name)async{
    var sub = await FirebaseFirestore.instance.collection('admin').doc(widget.email).collection('sites').where('site', isEqualTo: name).get();
    setState(() {
      locations = sub.docs;
      isLoading = false;
    });
  }

  getSuggestions()async{
    var sub = await FirebaseFirestore.instance.collection('admin').doc(widget.email).collection('sites').get();
    setState(() {
      List suggestions = sub.docs;
      for(int i=0;i<suggestions.length;i++){
        suggestionList.add(suggestions[i]['site']);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSuggestions();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CustomText(text: 'Locations'),
      ),
      body: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        child: Column(
          children: [
            ///search
            if(suggestionList.isNotEmpty)
              DropdownSearch<String>(
                mode: Mode.MENU,
                showSelectedItem: true,
                showSearchBox: true,
                items: suggestionList,
                showClearButton: true,
                dropdownSearchDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter location name',
                    contentPadding: EdgeInsets.all(ScreenUtil().setHeight(15)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black,width: 3)
                    )
                ),
                searchBoxDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black,width: 3)
                    )
                ),
                popupShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                maxHeight: MediaQuery.of(context).size.height/2,
                onChanged: (val){
                  if(val==null){
                    setState(() {
                      locations = null;
                    });
                  }else{
                    setState(() {
                      isLoading = true;
                    });
                    getLocations(val);
                  }
                },
              ),

            
            ///locations and buttons
            SizedBox(height: ScreenUtil().setHeight(30),),
            Expanded(
              child: Column(
                children: [
                  ///top space
                  // SizedBox(height: ScreenUtil().setHeight(140),),

                  ///locations
                  Expanded(
                    child: locations!=null?ListView.builder(
                      itemCount: locations.length,
                      itemBuilder: (context,i){
                        String location = locations[i]['site'];
                        String dueDate = locations[i]['dueDate'];
                        int accumulated = locations[i]['total'];
                        int budgeted = locations[i]['budgeted'];
                        double projectedCompletion = double.parse((accumulated/budgeted*100).toStringAsFixed(2));
                        String lat = locations[i]['lat'].toString();
                        String long = locations[i]['long'].toString();

                        return Padding(
                          padding:  EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding:  EdgeInsets.all(ScreenUtil().setHeight(25)),
                              child: Column(
                                children: [

                                  ///location
                                  CustomText(text: location,size: ScreenUtil().setSp(35)),

                                  ///due date
                                  Padding(
                                    padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(text: 'Due Date:',size: ScreenUtil().setSp(30),),
                                        CustomText(text: dueDate,size: ScreenUtil().setSp(30),),
                                      ],
                                    ),
                                  ),


                                  ///projected completion
                                  Padding(
                                    padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(text: 'Projected Completion:',size: ScreenUtil().setSp(30),),
                                        CustomText(text: projectedCompletion.toString()+"%",size: ScreenUtil().setSp(30),),
                                      ],
                                    ),
                                  ),

                                  ///latitude
                                  Padding(
                                    padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(text: 'Latitude:',size: ScreenUtil().setSp(30),),
                                        CustomText(text: lat,size: ScreenUtil().setSp(30),),
                                      ],
                                    ),
                                  ),

                                  ///longitude
                                  Padding(
                                    padding:  EdgeInsets.all(ScreenUtil().setWidth(15)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(text: 'Longitude:',size: ScreenUtil().setSp(30),),
                                        CustomText(text: long,size: ScreenUtil().setSp(30),),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ):
                    isLoading?
                    Center(child: CircularProgressIndicator(),):
                    Center(child: Container(),),
                  ),


                  ///copy
                  if(locations!=null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:ScreenUtil().setHeight(40)),
                    child: Button(
                      borderRadius: 10,
                      color: Constants.kButtonBlue,
                      text: 'Copy',
                      onclick: (){
                        String lat = locations[0]['lat'].toString();
                        String long = locations[0]['long'].toString();
                        Clipboard.setData(new ClipboardData(text: "$lat,$long"));
                        ToastBar(text: 'Latitude and Longitude copied to clipboard',color: Colors.green).show();
                      },
                    ),
                  ),
                  if(locations!=null)
                  SizedBox(height: ScreenUtil().setHeight(10),),

                  ///open in maps
                  if(locations!=null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:ScreenUtil().setHeight(40)),
                    child: Button(
                      borderRadius: 10,
                      color: Constants.kButtonPink,
                      text: 'Open in maps',
                      onclick: (){
                        String lat = locations[0]['lat'].toString();
                        String long = locations[0]['long'].toString();
                        launch('https://www.google.com/maps/search/?api=1&query=$lat,$long');
                      },
                    ),
                  ),
                  if(locations!=null)
                  SizedBox(height: ScreenUtil().setHeight(30),),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
