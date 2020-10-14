import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pfa_project_cloudhpc/views/main_drawer.dart';
import 'package:pfa_project_cloudhpc/views/publication_form.dart';
import 'package:pfa_project_cloudhpc/views/sign_up_view.dart';
import 'package:pfa_project_cloudhpc/widgets/value_tile.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthFormType authFormType;
  CollectionReference dataCrowsSensing =
      Firestore.instance.collection('crowdSensing');
  final String documentId = "";
  QuerySnapshot querySnapshot;

  @override
  void initState() {
    super.initState();
    getDataList().then((lists) {
      setState(() {
        querySnapshot = lists;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange[500],
        title: Text("Accueil"),
        actions: [],
      ),
      drawer: MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: showData(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(
          FontAwesomeIcons.plus,
          color: Colors.white,
        ),
        tooltip: "add publication",
        elevation: 4,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PublicationForm()));
        },
      ),
    );
  }

  Widget showData() {
    if (querySnapshot != null) {
      //  print("${querySnapshot.documents[0].data}");
      return ListView.builder(
        itemCount: querySnapshot.documents.length,
        primary: false,
        padding: EdgeInsets.only(top: 5, bottom: 10),
        itemBuilder: (context, i) {
          return Column(children: [
            Card(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: (querySnapshot
                                          .documents[i].data['weather'] !=
                                      null ||
                                  querySnapshot
                                          .documents[i].data['discovery'] !=
                                      null)
                              ? AssetImage("images/process.png")
                              : (querySnapshot.documents[i].data['user']
                                          ["imageProfil"] ==
                                      "images/anonymous.jpg")
                                  ? AssetImage("images/anonymous.jpg")
                                  :(querySnapshot.documents[i].data['user']
                          ["imageProfil"] ==null)?AssetImage("images/compte.jpg"): NetworkImage(
                                      querySnapshot.documents[i].data['user']
                                          ["imageProfil"],
                                    ),
                          radius: 35,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              querySnapshot.documents[i].data['weather'] !=
                                          null ||
                                      querySnapshot
                                              .documents[i].data['discovery'] !=
                                          null
                                  ? "System"
                                  : querySnapshot.documents[i].data['user']
                                              ["name"] !=
                                          null
                                      ? querySnapshot.documents[i].data['user']
                                          ["name"]
                                      : "Anonymous",
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              querySnapshot.documents[i].data['location'] !=
                                      null
                                  ? querySnapshot.documents[i].data['location']
                                      .toString()
                                  : "Emplacement non défini",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              querySnapshot.documents[i].data['date'] != null
                                  ? DateFormat("EEEE H:mm a").format(
                                      querySnapshot.documents[i].data['date']
                                          .toDate())
                                  : ' ',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Center(
                        child: Text(
                      querySnapshot.documents[i].data['commentaire'] != null
                          ? querySnapshot.documents[i].data['commentaire']
                          : '',
                      style: TextStyle(fontSize: 22),
                    )),
                    SizedBox(
                      height: 8,
                    ),
                    querySnapshot.documents[i].data['image'] != null
                        ? ClipRRect(
                            child: Image.network(
                              querySnapshot.documents[i].data['image'],
                              width: 390,
                              height: 230,
                              fit: BoxFit.fitHeight,
                            ),
                          )
                        : Container(),
                    querySnapshot.documents[i].data['weather'] != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                child: Divider(),
                                padding: EdgeInsets.only(top: 5),
                              ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ValueTile(
                                          "lever du soleil",
                                          querySnapshot.documents[i]
                                              .data['weather']['sunrise']
                                              ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: Center(
                                            child: Container(
                                          width: 1,
                                          height: 30,
                                        )),
                                      ),
                                      ValueTile(
                                          "Coucher du soleil",
                                          querySnapshot.documents[i]
                                              .data['weather']['sunset']),
                                    ]),
                                Padding(
                                  child: Divider(),
                                  padding: EdgeInsets.all(5),
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ValueTile(
                                          "Température",
                                          querySnapshot.documents[i]
                                              .data['weather']['temperature'].toString() +"°"),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: Center(
                                            child: Container(
                                          width: 1,
                                          height: 30,
                                        )),
                                      ),
                                      ValueTile(
                                          "Vent",
                                          querySnapshot.documents[i]
                                              .data['weather']['windSpeed']),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: Center(
                                            child: Container(
                                          width: 1,
                                          height: 30,
                                        )),
                                      ),
                                      ValueTile(
                                          "Humidité",
                                          querySnapshot.documents[i]
                                              .data['weather']['humidity']),
                                    ]),
                              Padding(
                                child: Divider(),
                                padding: EdgeInsets.all(5),
                              ),
                              ])
                        : Container(),

                    querySnapshot.documents[i].data['discovery'] != null
                        ? Center(
                            child: ValueTile(
                                '${querySnapshot.documents[i].data['discovery']['nearby']}',
                                ''),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Divider(
              color: Colors.white,
            ),
            SizedBox(
              height: 5,
            ),
          ]);
        },
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  getDataList() async {
    return await Firestore.instance
        .collection('crowdSensing')
        .orderBy("date", descending: true)
        .getDocuments();
  }
}
