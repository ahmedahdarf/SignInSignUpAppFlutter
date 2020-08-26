import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfa_project_cloudhpc/services/auth_service.dart';
import 'package:pfa_project_cloudhpc/views/camera_view.dart';
import 'package:pfa_project_cloudhpc/views/main_drawer.dart';
import 'package:pfa_project_cloudhpc/views/sign_up_view.dart';
import 'package:pfa_project_cloudhpc/widgets/provider_widget.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthFormType authFormType;

  int _currentIndex=0;
  @override
  Widget build(BuildContext context) {
    final tabs=[
      Center(child: Container(child: Text("Home",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold)),)),
      Center(child: Container(child: Text("Search",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold)),)),
      CameraView(),
      Center(child: Container(child: Text("Profile",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold)),)),
      Center(child: Container(child: Text("GPS",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold)),)),
    ];
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange[500],
        title: Text("Home"),
        actions: [

        /*  IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {

              Navigator.of(context).pushReplacementNamed("/convertUser");
            },
          )*/
        ],
      ),
      drawer: MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          child: tabs[_currentIndex]
        ),
      ),
     /*
     *
     *
     *
     *  bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.orange[500],
        iconSize: 35,
        items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home,color: Colors.white,),
              title: Text("Home",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: Colors.white),),
              backgroundColor: Colors.orange[500],


            ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search,color: Colors.white,),
              title: Text("Search",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),),
              backgroundColor: Colors.orange[500]
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera,color: Colors.white,),
              title: Text("Camera",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white)),
              backgroundColor: Colors.orange[500]
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person,color: Colors.white,),
              title: Text("Profile",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white)),
              backgroundColor: Colors.orange[500]
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.gps_fixed,color: Colors.white,),
              title: Text("GPS",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white)),
              backgroundColor: Colors.orange[500]
          ),


        ],
        onTap: (index){
          setState(() {
            _currentIndex=index;
          });
        },
      ),
     * */
    );
  }
}
