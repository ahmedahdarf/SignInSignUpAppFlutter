import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:pfa_project_cloudhpc/models/crowd_sensing.dart';
import 'package:pfa_project_cloudhpc/views/home_widget.dart';
import 'package:pfa_project_cloudhpc/widgets/provider_widget.dart';
import 'package:convert/convert.dart';
import 'package:image/image.dart' as IM;
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as Math;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PublicationForm extends StatefulWidget {
    @override
    _PublicationFormState createState() => _PublicationFormState();
}

class _PublicationFormState extends State<PublicationForm> {
    final GlobalKey<FormState> _formkey=GlobalKey<FormState>();
    GlobalKey _globalKey=GlobalKey();
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
    File _imageFile;
    List<Face> _faces;
    bool isLoading = false;
    ui.Image _image;


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
                "${place.locality}, ${place.country}";
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

       // if(_imageFile!=null){

            StorageReference storageReference = FirebaseStorage.instance
                .ref ()
                .child ("crowdSensing/IMG_${DateTime.now().millisecondsSinceEpoch}.png");
        RenderRepaintBoundary renderRepaintBoundary= _globalKey.currentContext.findRenderObject();
        ui.Image boxImg=  await renderRepaintBoundary.toImage(pixelRatio: 1);
        ByteData byteData=await  boxImg.toByteData(format: ui.ImageByteFormat.png);
        Uint8List uint8list=byteData.buffer.asUint8List();




            StorageUploadTask uploadTask = storageReference.putData (uint8list);
            StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
            imageUrl=await storageReference.getDownloadURL();
      //  }
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
    bool _isBlurred=false;
    Widget _decideImageView() {
        /*if (imageFile == null)
      return Text("No selected image");
    else {
      return Image.file(
        imageFile,
        width: 300,
        height: 250,
        fit: BoxFit.fill,
      );
    }*/
        return  isLoading
            ? Center(child: CircularProgressIndicator())
            : (_imageFile == null)
            ? Center(child: Text('No image selected'))
            : RepaintBoundary(
                key: _globalKey,
              child: FittedBox(
                  child: SizedBox(
                      width: _image.width.toDouble(),
                      height: _image.height.toDouble(),

                      child: CustomPaint(

                          painter: FacePainter(_image, _faces),


                      ),
                  ),
              ),
            );
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
                                        //_openGallery(context);
                                        _getImageAndDetectFaces(context,ImageSource.gallery);
                                    },
                                ),
                                Padding(
                                    padding: EdgeInsets.all(6.0),
                                ),
                                Divider(color: Colors.black,),
                                GestureDetector(
                                    child: Text("Camera"),
                                    onTap: () {
                                        //_openCamera(context);
                                        _getImageAndDetectFaces(context,ImageSource.camera);
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


    _getImageAndDetectFaces(BuildContext context,ImageSource source) async {
        final imageFile = await ImagePicker.pickImage(
            source: source
        );
        setState(() {
            isLoading = true;
        });
        final image = FirebaseVisionImage.fromFile(imageFile);
        IM.Image img;

        final faceDetector = FirebaseVision.instance.faceDetector(
            FaceDetectorOptions(
                mode: FaceDetectorMode.fast,
                enableLandmarks: true
            )
        );
        List<Face> faces = await faceDetector.processImage(image);


        if (mounted) {
            setState(() {
                _imageFile = imageFile;
                _faces = faces;
                _loadImage(_imageFile);
                //_imageFile=await writeToFile(pngBytes);
                // _imageFile=_image.toByteData(format: ui.ImageByteFormat.rawRgba) as File;

            });
        }
        Navigator.of(context).pop();
    }

    _loadImage(File file) async {
        final data = await file.readAsBytes();


        await decodeImageFromList(data).then(
                (value) => setState(() {
                _image = value;
                isLoading = false;
            }),
        );
    }
}


class FacePainter extends CustomPainter {
    ui.Image image;
    final List<Face> faces;
    final List<Rect> rects = [];
    final recorder = new ui.PictureRecorder();

    FacePainter(this.image, this.faces) {
        for (var i = 0; i < faces.length; i++) {
            rects.add(faces[i].boundingBox);
        }
    }

    @override
    void paint(ui.Canvas canvas, ui.Size size) {
        final radius=Math.min(size.width,size.height);
        final center =Offset(size.width/2,size.height/2);
        final Paint paint = Paint()
            ..style = PaintingStyle.fill
            ..strokeWidth = 19.0
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, .0)

            ..color = Colors.white;


        canvas.drawImage(image, Offset.zero, Paint());
        for (var i = 0; i < faces.length; i++) {
            canvas.drawOval(rects[i], paint);

        }
    }

    @override
    bool shouldRepaint(FacePainter oldDelegate) {
        return image != oldDelegate.image || faces != oldDelegate.faces;
    }
}