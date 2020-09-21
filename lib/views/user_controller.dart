

import 'dart:io';


import 'package:pfa_project_cloudhpc/models/user_class.dart';
import 'package:pfa_project_cloudhpc/services/aute_repo.dart';


class UserController {
  UserModel _currentUser;


  Future init;

  UserController() {
    init = initUser();
  }

  Future<UserModel> initUser() async {

    return _currentUser;
  }

  UserModel get currentUser => _currentUser;
  Future<void> uploadProfilePicture(File image) async {

  }


}
