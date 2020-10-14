import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:pfa_project_cloudhpc/services/auth_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:pfa_project_cloudhpc/services/auth_service.dart';
import 'package:pfa_project_cloudhpc/widgets/provider_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

enum AuthFormType { signUp, signIn, reset, anonymous, convert }

class SignUpView extends StatefulWidget {
  final AuthFormType authFormType;
  SignUpView({Key key, @required this.authFormType}) : super(key: key);
  @override
  _SignUpViewState createState() =>
      _SignUpViewState(authFormType: this.authFormType);
}

class _SignUpViewState extends State<SignUpView> {
  AuthFormType authFormType;
  String photourl;
  _SignUpViewState({this.authFormType});
  final formKey = GlobalKey<FormState>();
  String _email, _password, _name, _warning;

  void swithFormState(String state) {
    formKey.currentState.reset();
    if (state == "signUp") {
      setState(() {
        authFormType = AuthFormType.signUp;
      });
    } else if (state == 'home') {
      Navigator.of(context).pushReplacementNamed('/home');
      // Navigator.of(context).pop();
    } else {
      setState(() {
        authFormType = AuthFormType.signIn;
      });
    }
  }

  bool validate() {
    final form = formKey.currentState;
    if (authFormType == AuthFormType.anonymous) {
      return true;
    }
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit() async {
    if (validate()) {
      try {
        final auth = Provider.of(context).auth;
//      final auth1=locator.get<AuthRepo>();
        switch (authFormType) {
          case AuthFormType.signUp:
            await auth.createUserWithEmailAndPassword(_email, _password, _name);
            Navigator.of(context).pushReplacementNamed("/home");
            break;
          case AuthFormType.signIn:
            await auth.signInWithEmailAndPassword(_email, _password);
            //  String url= await auth.getUserProfileImage(uid);

            Navigator.of(context).pushReplacementNamed("/home");
            break;
          case AuthFormType.reset:
            await auth.sendPasswordResetEmail(_email);
            _warning =
                "un lien de réinitialisation du mot de passe a été envoyé à $_email";
            setState(() {
              authFormType = AuthFormType.signIn;
            });
            break;
          case AuthFormType.anonymous:
            // TODO: Handle this case.
            //final aute=Provider.of(context).auth;
            await auth.signInAnonymously();
            Navigator.of(context).pushReplacementNamed("/home");
            break;
          case AuthFormType.convert:
            await auth.convertUserWithEmail(_email, _password, _name);
            Navigator.of(context).pop();
            break;
        }
      } catch (e) {
        print(e);
        setState(() {
          _warning = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    if (authFormType == AuthFormType.anonymous) {
      submit();
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.orange[500],
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitDoubleBounce(
                  color: Colors.white,
                ),
                Text(
                  "Chargement",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          color: Colors.orange[500],
          height: _height,
          width: _width,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: _height * 0.025,
                  ),
                  showAlerts(),
                  SizedBox(
                    height: _height * 0.025,
                  ),
                  buildHeaderText(),
                  SizedBox(
                    height: _height * 0.05,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: buildInputs() + buildButtons(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget showAlerts() {
    if (_warning != null) {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error),
            ),
            Expanded(
                child: AutoSizeText(
              _warning,
              maxLines: 3,
              style: TextStyle(color: Colors.black, fontSize: 18),
            )),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _warning = null;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: 0.0,
    );
  }

  AutoSizeText buildHeaderText() {
    String _headerText;
    if (authFormType == AuthFormType.signIn) {
      _headerText = "Se connecter";
    } else if (authFormType == AuthFormType.reset) {
      _headerText = "Réinitialiser le mot de passe";
    } else {
      _headerText = "Créer un nouveau compte";
    }
    return AutoSizeText(
      _headerText,
      style: TextStyle(
          fontSize: 32, color: Colors.white, fontWeight: FontWeight.w500),
      textAlign: TextAlign.center,
      maxLines: 1,
    );
  }

  bool _isVisible = true;
  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  List<Widget> buildInputs() {
    List<Widget> textFields = [];

    if (authFormType == AuthFormType.reset) {
      textFields.add(
        TextFormField(
          validator: EmailValidator.validate,
          style: TextStyle(fontSize: 22, color: Colors.black),
          decoration: buildSignUpInputDecoration("Email")
              .copyWith(prefixIcon: Icon(Icons.email)),
          onSaved: (val) => _email = val,
        ),
      );
      textFields.add(SizedBox(
        height: 15,
      ));
      return textFields;
    }
    // if were in the sign un state add name
    if ([AuthFormType.signUp, AuthFormType.convert].contains(authFormType)) {
      textFields.add(
        TextFormField(
          validator: NameValidator.validate,
          style: TextStyle(fontSize: 22, color: Colors.black),
          decoration: buildSignUpInputDecoration("Nom")
              .copyWith(prefixIcon: Icon(Icons.account_circle)),
          onSaved: (val) => _name = val,
        ),
      );
      textFields.add(SizedBox(
        height: 15,
      ));
    }
    // add email & password
    textFields.add(
      TextFormField(
        validator: EmailValidator.validate,
        style: TextStyle(
          fontSize: 22,
        ),
        decoration: buildSignUpInputDecoration("Email").copyWith(
            prefixIcon: Icon(
          Icons.email,
          color: Colors.grey,
        )),
        onSaved: (val) => _email = val,
      ),
    );

    textFields.add(SizedBox(
      height: 15,
    ));
    textFields.add(
      TextFormField(
        validator: PasswordValidator.validate,
        style: TextStyle(
          fontSize: 22,
        ),
        obscureText: _isVisible,
        decoration: buildSignUpInputDecoration("Mot de passe").copyWith(
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.grey,
          ),
          suffixIcon: true
              ? IconButton(
                  icon: _isVisible
                      ? Icon(
                          Icons.visibility_off,
                          color: Colors.grey,
                        )
                      : Icon(
                          Icons.visibility,
                          color: Colors.grey,
                        ),
                  onPressed: _toggleVisibility,
                  color: Colors.grey,
                )
              : null,
        ),
        onSaved: (val) => _password = val,
      ),
    );
    textFields.add(SizedBox(
      height: 15,
    ));

    return textFields;
  }

  List<Widget> buildButtons() {
    String _switchButtonText, _newFormState, _submitButtonText;
    bool _showForgotPassword = false;
    bool _showSocial = true;
    if (authFormType == AuthFormType.signIn) {
      _switchButtonText = "Créer nouveau compte";
      _newFormState = "signUp";
      _submitButtonText = "Se connecter";
      _showForgotPassword = true;
    } else if (authFormType == AuthFormType.reset) {
      _switchButtonText = "Revenir pour vous connecter";
      _newFormState = "signIn";
      _submitButtonText = "Envoyer";
      _showSocial = false;
    } else if (authFormType == AuthFormType.convert) {
      _switchButtonText = "Annuler";
      _newFormState = "home";
      _submitButtonText = "S'inscrire";
    } else {
      _switchButtonText = "Avoir un compte? Se connecter";
      _newFormState = "signIn";
      _submitButtonText = "S'inscrire";
    }
    return [
      Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          color: Colors.white,
          //textColor: Colors.white,
          onPressed: submit,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _submitButtonText,
              style: TextStyle(fontSize: 25, color: Colors.orange[500]),
            ),
          ),
        ),
      ),
      showForgotPassword(_showForgotPassword),
      SizedBox(
        height: 0.0,
      ),
      FlatButton(
        child: Text(
          _switchButtonText,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        onPressed: () {
          swithFormState(_newFormState);
        },
      ),
      buildSocialIcons(_showSocial),
    ];
  }

  InputDecoration buildSignUpInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      focusColor: Colors.grey,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.0)),
      contentPadding:
          const EdgeInsets.only(bottom: 10.0, left: 14.0, top: 10.0),
    );
  }

  Widget showForgotPassword(bool visible) {
    return Visibility(
      child: FlatButton(
        child: Text(
          "Mot de passe oublié?",
          style: TextStyle(color: Colors.white, fontSize: 19),
        ),
        onPressed: () {
          setState(() {
            authFormType = AuthFormType.reset;
          });
        },
      ),
      visible: visible,
    );
  }

  Widget buildSocialIcons(bool visible) {
    final auth = Provider.of(context).auth;
    return Visibility(
      child: Column(
        children: [
          Divider(
            color: Colors.white,
          ),
          SizedBox(
            height: 5.0,
          ),
          GoogleSignInButton(
            text: "Connectez-vous avec Google ",
            onPressed: () async {
              try {
                if (authFormType == AuthFormType.convert) {
                  await auth.convertWithGoogle();
                  Navigator.of(context).pop;
                } else {
                  await auth.signWithGoogle();
                  Navigator.of(context).pushReplacementNamed("/home");
                }
              } catch (e) {
                setState(() {
                  _warning = e.message;
                });
              }
            },
          )
        ],
      ),
      visible: visible,
    );
  }
}
