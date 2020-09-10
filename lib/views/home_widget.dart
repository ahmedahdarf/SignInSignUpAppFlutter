import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pfa_project_cloudhpc/services/auth_service.dart';
import 'package:pfa_project_cloudhpc/views/camera_view.dart';
import 'package:pfa_project_cloudhpc/views/main_drawer.dart';
import 'package:pfa_project_cloudhpc/views/publication_form.dart';
import 'package:pfa_project_cloudhpc/views/sign_up_view.dart';
import 'package:pfa_project_cloudhpc/widgets/provider_widget.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthFormType authFormType;
  CollectionReference dataCrowsSensing = Firestore.instance.collection(
      'crowdSensing');
  int _currentIndex = 0;
  final String documentId = "";
  QuerySnapshot querySnapshot;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataList().then(
            (lists) {
          setState(() {
            querySnapshot = lists;
          });

        }
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange[500],
        title: Text("Home"),
        actions: [
        ],
      ),
      drawer: MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child:  showData()
        ,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(FontAwesomeIcons.plus, color: Colors.white,),
        tooltip: "add publication",
        elevation: 4,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PublicationForm()));
        },
      ),

    );
  }

  Widget showData() {
    if(querySnapshot!=null){
      //  print("${querySnapshot.documents[0].data}");
      return ListView.builder(
        itemCount: querySnapshot.documents.length,
        primary: false,
        padding: EdgeInsets.only(top: 5,bottom: 10),
        itemBuilder: (context,i){
          return  Column(
              children: [Card(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage:(querySnapshot.documents[i].data['user']["imageProfil"]=="images/anonymous.jpg")?AssetImage("images/anonymous.jpg"):  NetworkImage(querySnapshot.documents[i].data['user']["imageProfil"],),
                            radius: 35,
                          ),
                          SizedBox(width: 8,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(querySnapshot.documents[i].data['user']["name"]??"Anonymous",style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
                              SizedBox(height: 5,),
                              AutoSizeText(querySnapshot.documents[i].data['location']??"Location Undefined",style: TextStyle(fontSize: 14, ),maxLines: 2,textAlign: TextAlign.center,),
                              SizedBox(height: 5,),
                              AutoSizeText(DateFormat("EEEE H:mm a").format(querySnapshot.documents[i].data['date'].toDate()),style: TextStyle(fontSize: 14, ),maxLines: 2,textAlign: TextAlign.center,),

                            ],
                          ),


                        ],
                      ),
                      SizedBox(height: 5,),
                      Center(child: Text(querySnapshot.documents[i].data['commentaire'],style: TextStyle(fontSize: 25),)),
                      querySnapshot.documents[i].data['image']!=null?
                      Center(
                        child: ClipRRect(
                          //width: MediaQuery.of(context).size.width,

                          child: Image.network(querySnapshot.documents[i].data['image'],width: 380,height: 250,  fit: BoxFit.fill,
                          ),


                        ),
                      ):Container(),

                    ],

                  ),
                ),
              ),
                SizedBox(height: 15,),


              ]
          );




        },


      );
    }else{
      return Center(child: CircularProgressIndicator());
    }
  }

  getDataList() async {
    return await Firestore.instance.collection('crowdSensing').orderBy("date",descending: true).getDocuments();
  }
}