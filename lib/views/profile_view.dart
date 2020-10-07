import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pfa_project_cloudhpc/services/auth_service.dart';
import 'package:pfa_project_cloudhpc/widgets/provider_widget.dart';

class ProfilView extends StatefulWidget {
  @override
  _ProfilViewState createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  File _image;
  bool _isloadin = false;
  String _uploadFileUrl = "";
  String urlUid;

  void getUserProfilePicDowloadUrl() async {
    try {
      final FirebaseUser user = await AuthService().getCurrentUser();
      final uid = user.uid;
      print(" ****** $uid   ****");
      var storageRef =
          FirebaseStorage.instance.ref().child("users/profile/$uid");

      setState(() async {
        _uploadFileUrl = await storageRef.getDownloadURL();
        await AuthService().updateProfilePic(_uploadFileUrl);
        // print("url de la photo $_uploadFileUrl");

        urlUid = await storageRef.getName();
        _isloadin = true;
      });

      print("uid ${await storageRef.getName()}");
      print("uid =$_uploadFileUrl");
    } catch (e) {
      print(e);
    }
  }

  Widget showPict(context, snapshot) {
    if (snapshot.isAnonymous == true) {
      return Align(
          alignment: Alignment.center,
          child: CircleAvatar(
            radius: 100,
            backgroundImage: AssetImage('images/anonymous.jpg'),
          ));
    }
    if (_image != null) {
      return CircleAvatar(
        radius: 100,
        backgroundColor: Colors.orange,
        child: ClipOval(
          child: SizedBox(
              width: 180,
              height: 180,
              child: CircleAvatar(
                child: ClipOval(
                  child: Image.file(_image),
                ),
              )),
        ),
      );
    } else {
      setState(() {
        _uploadFileUrl = snapshot.data.photoUrl;
      });
      if (_uploadFileUrl != null) {
        return CircleAvatar(
          radius: 100,
          backgroundColor: Colors.orange,
          child: ClipOval(
            child: SizedBox(
                width: 180,
                height: 180,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    _uploadFileUrl,
                  ),
                )),
          ),
        );
      } else {
        return CircleAvatar(
          radius: 100,
          backgroundColor: Colors.orange,
          child: ClipOval(
            child: SizedBox(
                width: 180,
                height: 180,
                child: Image.asset("images/compte.jpg")),
          ),
        );
      }
    }
  }

  Widget displayUserinfo(context, snapshot) {
    final user = snapshot.data;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            user.isAnonymous == true
                ? Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: AssetImage('images/anonymous.jpg'),
                    ))
                : Row(
                    children: [
                      Align(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: user.photoUrl != null
                                ? NetworkImage(user.photoUrl)
                                : AssetImage('images/compte.jpg'),
                          )),
                      Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: IconButton(
                          icon: Icon(
                            FontAwesomeIcons.camera,
                            size: 36,
                          ),
                          onPressed: () {
                            getImage();
                            //uploadFile(context, snapshot);
                          },
                        ),
                      )
                    ],
                  )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    child: Text(
                      "Nom: ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    child: Text(
                      " ${user.displayName ?? "Anonymous"}",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 60.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Icon(FontAwesomeIcons.pen),
                      ),
                    ),
                  )
                ]),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Card(
          elevation: 1,
          margin: EdgeInsets.all(5),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Text(
                        "Email: ",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      child: Text(
                        " ${user.email ?? "Anonymous"}",
                        style: TextStyle(
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ]),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 300),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Icon(FontAwesomeIcons.pen),
                    ),
                  ),
                ),
              )
            ]),
          ),
        ),
        Card(
          elevation: 2,
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Crée le",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Crée : ${DateFormat("dd/MM/yyyy").format(user.metadata.creationTime)}",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ]),
        ),
        showSignOut(context, user.isAnonymous, snapshot),
      ],
    );
  }

  Widget showSignOut(context, bool isAnonymous, snapshot) {
    if (isAnonymous == true) {
      return RaisedButton(
        child: Text("Connectez-vous pour enregistrer vos données"),
        onPressed: () {
          Navigator.of(context).pushReplacementNamed("/convertUser");
        },
      );
    } else {
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  color: Colors.orange,
                  child: Text(
                    "Annuler",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  elevation: 4,
                  splashColor: Colors.orange,
                ),
                SizedBox(
                  width: 10,
                ),
                RaisedButton(
                  color: Colors.orange,
                  child: Text("Submit",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  onPressed: () {
                    uploadFile(context, snapshot);
                  },
                  elevation: 4,
                  splashColor: Colors.orange,
                )
              ],
            ),
          ]);
    }
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _image.path,
    );
    setState(() {
      _image = cropped ?? _image;
    });
  }

  void _clear() {
    setState(() {
      _image = null;
    });
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    File cropped = await ImageCropper.cropImage(
      sourcePath: image.path,
    );
    setState(() {
      _image = image;
    });
    /*setState(() {
     _image=image;
   });*/
    // await _cropImage();
    // await uploadFile(context, snapshot);
  }

  Future uploadFile(BuildContext context, snapshot) async {
    //  final FirebaseStorage firebaseStorage;//=FirebaseStorage.instance
    //FirebaseStorage(storageBucket: "gs://pfa-projet-5d592.appspot.com");
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child("users/profile/${snapshot.data.uid}");
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    print('Fichier téléchargé ${snapshot.data.uid}');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadFileUrl = fileURL;
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Container(
            child: Text("Image Uploaded"),
          ),
        ));
      });
    });
    // return _uploadFileUrl;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /* setState(() {
      this.getUserProfilePicDowloadUrl();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of(context).auth;

    rebuildAllChildren(context);
    getUserProfilePicDowloadUrl();

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: Provider.of(context).auth.getCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (_uploadFileUrl == null) {
                    setState(() {
                      getUserProfilePicDowloadUrl();
                    });
                  }
                  return displayUserinfo(context, snapshot);
                } else {
                  return CircularProgressIndicator();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }
}
