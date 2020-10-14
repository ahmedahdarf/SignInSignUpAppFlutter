import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/fenetre_dialogue.dart';

class FirstView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: _width,
        color: Colors.orange[500],
        height: _height,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: _height * 0.10,
                  ),
                  Text(
                    "Bienvenue",
                    style: TextStyle(fontSize: 44, color: Colors.white),
                  ),
                  SizedBox(
                    height: _height * 0.10,
                  ),
                  AutoSizeText(
                    "Cette application va vous aider à trouver la route sécurisée",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  SizedBox(
                    height: _height * 0.15,
                  ),
                  RaisedButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                      child: Text(
                        "Commencer",
                        style: TextStyle(
                            color: Colors.orange[500],
                            fontSize: 28,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => FenetreDialog(
                                title:
                                    "Souhaitez-vous créer un nouveau compte ?",
                                description:
                                    "Avec un compte vous pouvez consulter le fils d'actualités et de participer à la collection de données",
                                primaryBtnText: "S'inscrire",
                                primaryBtnRoute: "/signUp",
                                secondaryBtnText: "Peut-être plus tard",
                                secondaryBtnRoute: "/anonymousSignIn",
                              ));
                    },
                  ),
                  SizedBox(
                    height: _height * 0.10,
                  ),
                  FlatButton(
                    child: Text(
                      "Se connecter",
                      style: TextStyle(fontSize: 26, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).popAndPushNamed("/signIn");
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
