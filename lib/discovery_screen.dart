import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class DiscoveryPage extends StatefulWidget {
  /// If true, discovery starts on page start, otherwise user must press action button.
  final bool start;

  const DiscoveryPage({this.start = true});

  @override
  _DiscoveryPage createState() => new _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> {
  CollectionReference discoveries =
      Firestore.instance.collection('crowdSensing');
  final Geolocator _geolocator = Geolocator();
  Position _position;
  Timer _timer;
  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>();
  bool isDiscovering;
  String _currentAddress;

  _DiscoveryPage();

  @override
  void initState() {
    super.initState();

    isDiscovering = widget.start;

    if (isDiscovering) {
      _startDiscovery();
    }
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _restartDiscovery();
    });
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  _getCurrentLocation() async {
    await _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _position = position;
        print('CURRENT POS: $_position');
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await _geolocator.placemarkFromCoordinates(
          _position.latitude, _position.latitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "[${_position.latitude != null ? _position.latitude : ''},${_position.latitude != null ? _position.latitude : ''}],${place.country}";
      });
      print("$_currentAddress");
    } catch (e) {
      print(e);
    }
  }

  _startDiscovery() async {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        bool exist = checkIfExist(
            (element) => element.device.address == r.device.address);
        if (exist) {
          results.add(r);
        }
      });
    });
    _streamSubscription.onDone(() async {
      setState(() {
        isDiscovering = false;
      });
      await _getCurrentLocation();
      print(results.length);

      if (results.length >= 1) {
        print(results.length);
        discoveries.add({
          'commentaire': 'Embouteillage', //modifier le commentaire plus tard
          'date': DateTime.now(),
          'location': _currentAddress,
          'discovery': {
            'location': _position.toJson(),
            'latitude': _position.latitude,
            'longtitude': _position.longitude,
            'nearby': results.length,
          }
        });
      }
    });
  }

  bool checkIfExist(bool test(BluetoothDiscoveryResult element)) {
    for (BluetoothDiscoveryResult element in results) {
      if (test(element)) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(
          "Détection par bluetooth",
        ),
      ),
      body: isDiscovering
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Détecter ",
                  style: TextStyle(fontWeight: FontWeight.w200, fontSize: 25),
                ),
                Padding(padding: new EdgeInsets.all(10.0)),
                Center(
                    child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                )),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Badge(
                    badgeColor: Colors.black,
                    shape: BadgeShape.circle,
                    borderRadius: 20,
                    badgeContent: Text(
                      results.length.toString(),
                      style: new TextStyle(fontSize: 100, color: Colors.white),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.orangeAccent,
                      size: 200,
                    ),
                  ),
                  Text(
                    "Les gens près de chez vous ",
                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 25),
                  ),
                ],
              ),
            ),
    );
  }
}
