import 'package:flutter/material.dart';
import 'package:pfa_project_cloudhpc/services/auth_service.dart';
import 'package:pfa_project_cloudhpc/widgets/provider_widget.dart';


class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: () async{
              try{
                AuthService aute=Provider.of(context).auth;
                await aute.signOut();
                print("Se deconnecter");

              }catch(e){
                print(e);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed("/convertUser");
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          child: Container(
            child: Text("Bien venue dans l'application vous êtes connecter  !",style: TextStyle(fontSize: 25,),textAlign: TextAlign.center,),
          ),
        ),
      ),
    );
  }
}
