

import 'dart:io';

import 'package:pfa_project_cloudhpc/locator.dart';
import 'package:pfa_project_cloudhpc/models/user_class.dart';
import 'package:pfa_project_cloudhpc/services/aute_repo.dart';
import 'package:pfa_project_cloudhpc/services/storage_repo.dart';

class UserController {
  UserModel _currentUser;
  AuthRepo _authRepo = locator.get<AuthRepo>();
  StorageRepo _storageRepo=locator.get<StorageRepo>();

  Future init;

  UserController() {
    init = initUser();
  }

  Future<UserModel> initUser() async {
    _currentUser = await _authRepo.getUser();
    return _currentUser;
  }

  UserModel get currentUser => _currentUser;
  Future<void> uploadProfilePicture(File image) async {
    _currentUser.avatarUrl= await locator.get<StorageRepo>().uploadFile(image);
  }

  Future<String> getDownloadUrl ()async{
    await _storageRepo.getUserProfileImageDownloadUrl(currentUser.uid);
  }
  Future<void> signInWithEmailAndPassword({String email,String password}) async{

    _currentUser= await _authRepo.signInWithEmailAndPassword(email: email,password: password);
    _currentUser.avatarUrl=await getDownloadUrl();
  }


}
