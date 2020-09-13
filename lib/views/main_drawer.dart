import 'package:flutter/material.dart';
import 'package:pfa_project_cloudhpc/services/auth_service.dart';
import 'package:pfa_project_cloudhpc/views/camera_view.dart';
import 'package:pfa_project_cloudhpc/views/map_view.dart';
import 'package:pfa_project_cloudhpc/views/photo_view.dart';
import 'package:pfa_project_cloudhpc/views/profile_view.dart';
import 'package:pfa_project_cloudhpc/widgets/provider_widget.dart';


class MainDrawer extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Drawer(
            child: ListView(
                children: <Widget>[
                    DrawerHeader(
                        child: Center(

                            child: PhotoProfil(),
                        ),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.orange[500],Colors.amberAccent])
                        ),
                    ),
                    ListTile(
                        leading: Icon(Icons.home),
                        title: Text("Home",style: TextStyle(fontSize: 15),),
                        onTap: (){
                            Navigator.of(context).pop();
                            //Navigator.push(context, MaterialPageRoute(builder: (context)=> new Quiz()));
                        },),
                    Divider(color: Colors.deepOrangeAccent,),
                    ListTile(
                        leading: Icon(Icons.search),
                        title: Text("Search",style: TextStyle(fontSize: 15),),
                        onTap: (){
                            Navigator.of(context).pop();
                            //Navigator.push(context, MaterialPageRoute(builder: (context)=> new Weather()));
                        },),
                    Divider(color: Colors.deepOrangeAccent,),
                    ListTile(
                        leading: Icon(Icons.photo_camera),
                        title: Text("Camera",style: TextStyle(fontSize: 15),),
                        onTap: (){
                            Navigator.of(context).pop();
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> CameraView()));
                        },),
                    Divider(color: Colors.deepOrangeAccent,),
                    ListTile(
                        leading: Icon(Icons.my_location),
                        title: Text("GPS",style: TextStyle(fontSize: 15)),
                        onTap: (){
                            Navigator.of(context).pop();
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> new MapView()));
                        },),
                    Divider(color: Colors.deepOrangeAccent,),
                    ListTile(
                        leading: Icon(Icons.person),
                        title: Text("Profil",style: TextStyle(fontSize: 15),),
                        onTap: (){
                            Navigator.of(context).pop();
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilView()));
                        },),
                    Divider(color: Colors.deepOrangeAccent,),
                    ListTile(
                        leading: Icon(Icons.arrow_back),
                        title: Text("Se deconnecter",style: TextStyle(fontSize: 15),),
                        onTap: () async{
                            Navigator.of(context).pop();
                            try{
                                AuthService aute=Provider.of(context).auth;
                                await aute.signOut();
                                print("Se deconnecter");

                            }catch(e){
                                print(e);
                            }
                        },)
                ],
            ),
        );
    }
}