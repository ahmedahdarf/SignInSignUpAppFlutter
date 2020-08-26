 import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:pfa_project_cloudhpc/locator.dart';
import 'package:pfa_project_cloudhpc/models/user_class.dart';
import 'package:pfa_project_cloudhpc/services/aute_repo.dart';

class StorageRepo{
  FirebaseStorage  storage=FirebaseStorage(storageBucket: "gs://pfa-projet-5d592.appspot.com");
  AuthRepo _authRepo=locator.get<AuthRepo>();


   Future<String> uploadFile(File file) async {

    var user= await _authRepo.getUser();
    var storageRef= storage.ref().child("user/profile/${user.uid}");
    var uploadTask= storageRef.putFile(file);
    var completeTask = await uploadTask.onComplete;
    String downloadUrl =await completeTask.ref.getDownloadURL();

    return downloadUrl;

  }

  Future<UserModel> signInWithEmailAndPassword({String email,String password})async{
   var authResult=await _authRepo.signInWithEmailAndPassword(email: email,password: password);

  }


  Future<String>getUserProfileImageDownloadUrl(String uid){
     var storageRef=storage.ref().child("user/profile/$uid}");
     return storageRef.getDownloadURL();
  }
 }