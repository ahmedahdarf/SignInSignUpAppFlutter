
import 'package:flutter/widgets.dart';
class User{
  String uid;
  User({this.uid});
}


class UserKnown extends User{
   String email,password,image;
   UserKnown({uid,this.email,this.password,this.image}):super(uid:uid);
   // formatting for upload to firebase when creating the user infos
   Map<String,dynamic> toJson()=>{
      "image":image
   };
}

class UserModel {
  String uid;
  String displayName;
  String avatarUrl;
  String email;

  UserModel(this.uid, {this.displayName, this.avatarUrl,this.email});
}

