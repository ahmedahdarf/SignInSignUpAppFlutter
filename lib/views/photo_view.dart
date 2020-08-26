import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pfa_project_cloudhpc/widgets/provider_widget.dart';


class PhotoProfil extends StatelessWidget {
  final String imageUrl;
  final Function onTap;

  const PhotoProfil({ this.imageUrl, this.onTap}) ;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of(context).auth.getCurrentUser(),
      builder: (context,snapshot){
        try{
    if(snapshot.connectionState==ConnectionState.done){
        if (snapshot.data.isAnonymous==true){
          return SingleChildScrollView(
            child: Column(
              children: [
                Align(
                alignment: Alignment.center,
                child:CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('images/anonymous.jpg'),
                )
    ),
                Align(
                    alignment: Alignment.center,
                    child:Text("Anonymous",style: TextStyle(fontSize: 16),)
                ),

        ]
            ),
          );
        }else {
         return SingleChildScrollView(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children:[

               Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: snapshot.data.photoUrl != null ? NetworkImage(
                        snapshot.data.photoUrl) : Image.asset("images/compte.jpg"),
                  )
              ),
               Align(
                   alignment: Alignment.center,
                   child: Text(snapshot.data.displayName??"Anonymous",style: TextStyle(fontSize: 18),),
                   )
               
             ]
           ),
         );
        }
    }
      }
      catch(e){
        print(e);
          return Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage("images/compte.jpg"),
            ),
          );


    }}
    );
  }
}
