

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  File _selectedFile;
  bool inProcess=false;
  String _commentaire;
  final GlobalKey _key=GlobalKey<FormState>();
  final picker = ImagePicker();
  Widget getImageWidget(){
    if(_selectedFile!=null){
      return Image.file(
       _selectedFile,
        width: 450,
        height: 250,
        fit:BoxFit.cover,
      );
    }else{
        return Image.asset("images/camera.jpg",
          width: 400,
          height: 250,
          fit:BoxFit.cover,
        );
    }
  }

   getImage(ImageSource source) async{
    this.setState(() {
      inProcess=true;
    });
    File imageFile = await ImagePicker.pickImage(source: source);
   if(imageFile!=null){
     File cropper=await ImageCropper.cropImage(
       sourcePath: imageFile.path,
       aspectRatio: CropAspectRatio(ratioX: 1,ratioY: 1),
       compressQuality: 100,
       maxWidth: 700,
       maxHeight: 700,
       compressFormat: ImageCompressFormat.jpg,
       androidUiSettings:AndroidUiSettings(
           toolbarTitle: 'Cropper',
           toolbarColor: Colors.orange[500],
           toolbarWidgetColor: Colors.white,
           initAspectRatio: CropAspectRatioPreset.original,
           backgroundColor: Colors.orange[500],
           lockAspectRatio: false),


     );
     setState(() {
       _selectedFile=cropper;
       inProcess=false;
     });

   }else{
     this.setState(() {
       inProcess=false;

     });
   }


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camera"), backgroundColor: Colors.orange[500],),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.white,

          child: Form(

            key: _key,
            child: SingleChildScrollView(

              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  getImageWidget(),
                  SizedBox(height: 10.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      MaterialButton(
                        color:  Colors.orange[500],
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(Icons.camera_alt,size:50),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        onPressed: (){
                              getImage(ImageSource.camera);
                        },
                      ),
                      MaterialButton(
                        color:  Colors.orange[500],
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(Icons.image,size:50),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        onPressed: (){
                          getImage(ImageSource.gallery);
                        },
                      ),


                    ],
                  ),
             /*   SizedBox(height: 20.0,),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Ajouter Commentaire"
                  ),
                ),*/
                SizedBox(height: 20.0,),
                TextFormField( decoration: InputDecoration(
                    hintText: "Ajouter Commentaire"
                ),),

                SizedBox(height: 30.0,),
                FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  color: Colors.orange[500],

                onPressed: (){

                },
                  child: Text("Save",style: TextStyle(color: Colors.white,fontSize: 24),),
                ),



              ],
                ) ,

            ),
          ),
        ),
      ),
    );
  }
}
