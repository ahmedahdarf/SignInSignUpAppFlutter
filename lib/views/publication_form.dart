import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:pfa_project_cloudhpc/models/crowd_sensing.dart';
import 'package:pfa_project_cloudhpc/views/home_widget.dart';
import 'package:pfa_project_cloudhpc/widgets/provider_widget.dart';

class PublicationForm extends StatefulWidget {
  @override
  _PublicationFormState createState() => _PublicationFormState();
}

class _PublicationFormState extends State<PublicationForm> {
  final GlobalKey<FormState> _formkey=GlobalKey<FormState>();

  CrowdSensingParticip crowdSensingParticip;
  String userId;
  var user=null;
  String imageUrl;
  File imageFile;
  final picker = ImagePicker();
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  String _comment;
  String _currentAddress;
  LatLng _center ;
  Position currentLocation,_currentPosition;
  final firestoreInstance=Firestore.instance;


  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }
  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.locality}, ${place.country},${place.position.longitude}, ";
      });
      print("$_currentAddress");
    } catch (e) {
      print(e);
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getCurrentLocation();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of(context).auth.getCurrentUser(),
      builder: (context,snapshot){
        user=snapshot.data;
        userId=snapshot.data.uid;
        print("uid $userId");
        return Scaffold(
          appBar: AppBar(title: Text("Ajouter publication"),backgroundColor: Colors.orange[500],),
          body: SingleChildScrollView(
            child: Form(
              key: _formkey,
              autovalidate: true,

              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _decideImageView(),
                    SizedBox(height: 16,),
                    Text("Collecter les données ",textAlign: TextAlign.center,style: TextStyle(fontSize: 25),),
                    SizedBox(height: 16,),
                    ButtonTheme(
                      child: RaisedButton(
                        //splashColor: Colors.orange,
                        color: Colors.orange,
                        child: Text("Ajouter Une image",style: TextStyle(color: Colors.white),
                        ),
                        onPressed: (){
                          _showChoiseDialog(context);
                        },
                      ),),
                    SizedBox(height: 16,),
                    _buildCommentField(),
                  ],
                ),
              ),

            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.orange,
            child: Icon(FontAwesomeIcons.save,color: Colors.white,),

            elevation: 4,
            onPressed: (){
              //
              // saveIntoDb();
              print("saving data");
              saveData();
             // Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
            },
          ),
        );
      },
    );

  }

  Future saveData() async {
    if(!_formkey.currentState.validate()) return null ;
    _formkey.currentState.save();


   // print ( 'Fichier téléchargé ${snapshot.data.uid}' );

  if(imageFile!=null){
    StorageReference storageReference = FirebaseStorage.instance
        .ref ()
        .child ("crowdSensing/${imageFile.path}");

    StorageUploadTask uploadTask = storageReference.putFile (imageFile);
    StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
    imageUrl=await storageReference.getDownloadURL();

  }
  String nom,image;

    firestoreInstance.collection("crowdSensing").add({
      "user": {"uid":userId,"name":user.displayName??"anonyme","imageProfil":user.photoUrl??"images/anonymous.jpg"},
      "location":_currentAddress,
      "image":imageUrl,
      "commentaire":_comment,
      "date":DateTime.now()

    }).then((value) async {
     // print(value.documentID);

      print("success");

    }).catchError((e){
      print(e);
    });
    Navigator.of(context).pushReplacementNamed("/home");
  }
  Widget _decideImageView() {
    if (imageFile == null)
      return Text("No selected image");
    else {
      return Image.file(
        imageFile,
        width: 300,
        height: 250,
        fit: BoxFit.fill,
      );
    }
  }

  _openGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showChoiseDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Fais un choix !"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Divider(color: Colors.black,),

                  GestureDetector(
                    child: Text("Gallery"),
                    onTap: () {
                      _openGallery(context);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(6.0),
                  ),
                  Divider(color: Colors.black,),
                  GestureDetector(
                    child: Text("Camera"),
                    onTap: () {
                      _openCamera(context);
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _buildCommentField(){
     return TextFormField(
       decoration: InputDecoration(
         labelText: "Commentaire"
       ),
        keyboardType: TextInputType.text,
       style: TextStyle(fontSize: 20),
       validator: (String val){
          if(val.isEmpty){
            return "S'il vous plait ajouter un commentaire";
          }

          return null;

       },
       onSaved: (String val){
         setState(() {
           _comment=val;
         });

       },
     );
  }
}
