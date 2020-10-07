import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:password/password.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String uploadphoto;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Stream<String> get onAuthStateChanged =>
      _firebaseAuth.onAuthStateChanged.map((FirebaseUser user) => user?.uid);
  FirebaseUser _firebaseUser;
  SharedPreferences sharedPreferences;

// Email & password sign up
  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    final pwd = password;
    final algorithm = PBKDF2();
    final hash = Password.hash(pwd, algorithm);
    final currentUser = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: hash,
    );
    var userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = name;
    userUpdateInfo.photoUrl = "";
    await currentUser.user.updateProfile(userUpdateInfo);
    await currentUser.user.reload();
    return currentUser.user.uid;
  }

  Future updateProfilePic(picUrl) async {
    var userinfo = UserUpdateInfo();
    userinfo.photoUrl = picUrl;
    final currentUser = await _firebaseAuth.currentUser();
    currentUser.updateProfile(userinfo).then((value) {
      FirebaseAuth.instance.currentUser().then((value) {
        Firestore.instance
            .collection("/users")
            .where("uid", isEqualTo: currentUser.uid)
            .getDocuments()
            .then((doc) {
          Firestore.instance
              .document("/users/${doc.documents[0].documentID}")
              .updateData({'photoURL': picUrl}).then((value) {
            print("updated");
          }).catchError((e) {
            print(e);
          });
        }).catchError((e) {
          print(e);
        });
      }).catchError((e) {
        print(e);
      });
    }).catchError((e) {
      print(e);
    });
  }

// get user profile image
  Future<String> getUserProfileImage(String uid) async {
    var storageRef = FirebaseStorage.instance.ref().child("users/profile/$uid");
    return await storageRef.getDownloadURL().toString();
  }

// Email & password sign in
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    final pwd = password;
    final algorithm = PBKDF2();
    final hash = Password.hash(pwd, algorithm);
    return (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: hash))
        .user
        .uid;
  }

  // Get User Uid
  Future<String> getCurrentUID() async {
    return (await _firebaseAuth.currentUser()).uid;
  }

  Future<String> getUserProfilePicDowloadUrl(String uid) async {
    //final FirebaseUser user = await  AuthService().getCurrentUser();
    /// final uid = user.uid;
    // print(" ****** $uid");
    var storageRef = FirebaseStorage.instance.ref().child("users/profile/$uid");
    uploadphoto = await storageRef.getDownloadURL();
    print("uid ${await storageRef.getName()}");
    print("uid =");
    return uploadphoto;
  }

// Get current user
  Future getCurrentUser() async {
    return await _firebaseAuth.currentUser();
  }

// sign out
  signOut() {
    return _firebaseAuth.signOut();
  }

  // reset password

  Future sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // create anonymous User
  Future signInAnonymously() {
    return _firebaseAuth.signInAnonymously();
  }

  //
  Future convertUserWithEmail(
      String email, String password, String name) async {
    final currentUser = await _firebaseAuth.currentUser();
    final credential =
        EmailAuthProvider.getCredential(email: email, password: password);
    await currentUser.linkWithCredential(credential);
    var userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = name;
    userUpdateInfo.photoUrl = "";
    await currentUser.updateProfile(userUpdateInfo);
    await currentUser.reload();
  }
  //

  Future convertWithGoogle() async {
    final currentUser = await _firebaseAuth.currentUser();
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
    await currentUser.linkWithCredential(credential);
    var userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = _googleSignIn.currentUser.displayName;
    userUpdateInfo.photoUrl = "";
    await currentUser.updateProfile(userUpdateInfo);
    await currentUser.reload();
  }

  // sign in with google
  Future<String> signWithGoogle() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
    final id = (await _firebaseAuth.signInWithCredential(credential)).user.uid;
    _firebaseUser = (await _firebaseAuth.signInWithCredential(credential)).user;
    if (_firebaseUser != null) {
      final QuerySnapshot resultSnapshot = await Firestore.instance
          .collection("users")
          .where("id", isEqualTo: _firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documentSnapshots = resultSnapshot.documents;
      if (documentSnapshots.length == 0) {
        Firestore.instance
            .collection("users")
            .document(_firebaseUser.uid)
            .setData({
          "nom": _firebaseUser.displayName,
          "photoUrl": _firebaseUser.photoUrl,
          "id": _firebaseUser.uid,
          "email": _firebaseUser.email,
          "created": DateTime.now().millisecondsSinceEpoch.toString()
        });
        await sharedPreferences.setString("id", _firebaseUser.uid);
        await sharedPreferences.setString("email", _firebaseUser.email);
        await sharedPreferences.setString("nom", _firebaseUser.displayName);
        await sharedPreferences.setString("photoUrl", _firebaseUser.photoUrl);
        await sharedPreferences.setString(
            "created", DateTime.now().millisecondsSinceEpoch.toString());
        print("succeffl*********");
      } else {
        await sharedPreferences.setString("id", documentSnapshots[0]["uid"]);
        await sharedPreferences.setString(
            "email", documentSnapshots[0]["email"]);
        await sharedPreferences.setString("nom", documentSnapshots[0]["nom"]);
        await sharedPreferences.setString(
            "photoUrl", documentSnapshots[0]["photoUrl"]);
      }
    } else {
      print("errur");
    }

    return id;
  }
}

class NameValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Le Nom utilisateur ne peut pas être vide";
    }
    if (value.length < 3) {
      return "Le nom utilisateur doit être supérieur à 2 caractère";
    }
    if (value.length > 20) {
      return "Le nom utilisateur doit être inféreiur  à 20 caractère";
    }
    return null;
  }
}

class EmailValidator {
  static bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  static String validate(String value) {
    //bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
    if (value.isEmpty) {
      return "L'email ne peut pas être vide";
    }
    if (!isEmail(value)) {
      return "email invalid";
    }
    return null;
  }
}

class PasswordValidator {
  static String validate(String value) {
    Pattern pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{13,}$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
      return "Le mot de passe ne peut pas être vide";
    }
    if (value.length < 12 || !regex.hasMatch(value)) {
      return "mot de passe doit contenir 13 caractère au minimum\n avec des caractère spéciaux";
    }
    return null;
  }
}
