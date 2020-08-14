import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn=GoogleSignIn();
  Stream<String> get onAuthStateChanged =>
      _firebaseAuth.onAuthStateChanged.map((FirebaseUser user) => user?.uid);

// Email & password sign up
  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    final currentUser = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // update the username
    var userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = name;
    await currentUser.user.updateProfile(userUpdateInfo);
    await currentUser.user.reload();
    return currentUser.user.uid;
  }

// Email & password sign in
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user
        .uid;
  }

// sign out
  signOut() {
    return _firebaseAuth.signOut();
  }

  // reset password

  Future sendPasswordResetEmail(String email) async{
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // create anonymous User
  Future signInAnonymously(){
    return _firebaseAuth.signInAnonymously();
  }
  //
  Future convertUserWithEmail(String email, String password, String name)async{
    final currentUser= await _firebaseAuth.currentUser();
    final credential =EmailAuthProvider.getCredential(email: email,password:  password);
    await currentUser.linkWithCredential(credential);
    var userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = name;
    await currentUser.updateProfile(userUpdateInfo);
    await currentUser.reload();

  }
  //

  Future convertWithGoogle() async{
    final currentUser=await _firebaseAuth.currentUser();
    final GoogleSignInAccount account=await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth=await account.authentication;
    final AuthCredential  credential =GoogleAuthProvider.getCredential(
        idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
    await currentUser.linkWithCredential(credential);
    var userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = _googleSignIn.currentUser.displayName;
    await currentUser.updateProfile(userUpdateInfo);
    await currentUser.reload();
  }

  // sign in with google
  Future<String> signWithGoogle() async{
    final GoogleSignInAccount account=await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth=await account.authentication;
    final AuthCredential  credential =GoogleAuthProvider.getCredential(
        idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
    return (await _firebaseAuth.signInWithCredential(credential)).user.uid;
  }
}

class NameValidator{
  static String validate(String value){
    if(value.isEmpty){
      return "Le Nom utilisateur ne peut pas être vide";
    }
    if(value.length <3){
      return "Le nom utilisateur doit être supérieur à 2 caractère";
    }
    if(value.length>20){
      return "Le nom utilisateur doit être inféreiur  à 20 caractère";
    }
    return null;
  }
}
class EmailValidator{
  static String validate(String value){
    if(value.isEmpty){
      return "L'email ne peut pas être vide";
    }
    return null;
  }
}
class PasswordValidator{
  static String validate(String value){
    if(value.isEmpty){
      return "Le mot de passe ne peut pas être vide";
    }
    if(value.length<7){
      return "Le mot de passe doit contenir 8 caractère au minimum";
    }
    return null;
  }
}