import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfa_project_cloudhpc/api/api_keys.dart';
import 'package:pfa_project_cloudhpc/api/weather_api_client.dart';
import 'package:pfa_project_cloudhpc/bloc/weather_bloc.dart';
import 'package:pfa_project_cloudhpc/bloc/weather_event.dart';
import 'package:pfa_project_cloudhpc/bloc/weather_state.dart';
import 'package:pfa_project_cloudhpc/repository/weather_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa_project_cloudhpc/utils/converters.dart';
import 'package:pfa_project_cloudhpc/widgets/weather_widget.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models/weather.dart';

enum OptionsMenu { changeCity, settings }

class WeatherScreen extends StatefulWidget {
  final WeatherRepository weatherRepository = WeatherRepository(
      weatherApiClient: WeatherApiClient(
          httpClient: http.Client(), apiKey: ApiKey.OPEN_WEATHER_MAP));
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  CollectionReference _weather = Firestore.instance.collection('crowdSensing');
  final Geolocator _geolocator = Geolocator();
  Position _position;
  _getCurrentLocation() async {
    await _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _position = position;
        print('CURRENT POS: $_position');
      });
    }).catchError((e) {
      print(e);
    });
  }

  WeatherBloc _weatherBloc;
  String _cityName = 'kenitra';
  AnimationController _fadeController;
  Animation<double> _fadeAnimation;
  Future<void> addWeather(Weather weather) {
    // Call the user's CollectionReference to add a new user
    return _weather
        .add({
          'commentaire': '${weather.cityName}: ${weather.description}',
          'location': "${weather.cityName}",
          'date': DateTime.now(),
          'weather': {
            'temperature':
                weather.temperature.as(TemperatureUnit.celsius).round(),
            'time': DateFormat('yMd').format(
                DateTime.fromMillisecondsSinceEpoch(weather.time * 1000)),
            'sunrise': DateFormat('h:m a').format(
                DateTime.fromMillisecondsSinceEpoch(weather.sunrise * 1000)),
            'sunset': DateFormat('h:m a').format(
                DateTime.fromMillisecondsSinceEpoch(weather.sunset * 1000)),
            'humidity': weather.humidity.toString() + '%',
            'windSpeed': weather.windSpeed.toString() + 'm/s',
          }
        })
        .then((value) => print("add new weather"))
        .catchError((error) => print("Failed to add weather: $error"));
  }

  @override
  void initState() {
    super.initState();
    _weatherBloc = WeatherBloc(weatherRepository: widget.weatherRepository);
    _fetchWeatherWithLocation().catchError((error) {
      _fetchWeatherWithCity();
    });
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
        title: Text(
          "Météo",
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showCityChangeDialog,
          )
        ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: BlocBuilder(
                bloc: _weatherBloc,
                // ignore: missing_return
                builder: (_, WeatherState weatherState) {
                  if (weatherState is WeatherLoaded) {
                    this._cityName = weatherState.weather.cityName;
                    _fadeController.reset();
                    _fadeController.forward();
                    addWeather(weatherState.weather);
                    return WeatherWidget(
                      weather: weatherState.weather,
                    );
                  } else if (weatherState is WeatherError ||
                      weatherState is WeatherEmpty) {
                    String errorText = 'Une erreur s est produite lors de la récupération des données météorologiques';
                    if (weatherState is WeatherError) {
                      if (weatherState.errorCode == 404) {
                        errorText =
                            'Nous avons du mal à récupérer la météo pour $_cityName';
                      }
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 24,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          errorText,
                          style: TextStyle(),
                        ),
                        FlatButton(
                          child: Text(
                            "Réessayer",
                            style: TextStyle(),
                          ),
                          onPressed: _fetchWeatherWithCity,
                        )
                      ],
                    );
                  } else if (weatherState is WeatherLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    );
                  }
                }),
          ),
        ),
      ),
    );
  }

  _fetchWeatherWithCity() {
    _weatherBloc.dispatch(FetchWeather(cityName: _cityName));
  }

  void _showCityChangeDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Changer de ville', style: TextStyle(color: Colors.black)),
            actions: [
              FlatButton(
                child: Text(
                  'ok',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                onPressed: () {
                  _fetchWeatherWithCity();
                  Navigator.of(context).pop();
                },
              ),
            ],
            content: TextField(
              autofocus: true,
              onChanged: (text) {
                _cityName = text;
              },
              decoration: InputDecoration(
                  hintText: 'Nom de votre ville',
                  hintStyle: TextStyle(color: Colors.black),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _fetchWeatherWithLocation().catchError((error) {
                        _fetchWeatherWithCity();
                      });
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.my_location,
                      color: Colors.black,
                      size: 16,
                    ),
                  )),
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.black,
            ),
          );
        });
  }

  _fetchWeatherWithLocation() async {
    var permissionHandler = PermissionHandler();
    var permissionResult = await permissionHandler
        .requestPermissions([PermissionGroup.locationWhenInUse]);

    switch (permissionResult[PermissionGroup.locationWhenInUse]) {
      case PermissionStatus.denied:
      case PermissionStatus.unknown:
        print('autorisation de localisation refusée');
        _showLocationDeniedDialog(permissionHandler);
        throw Error();
    }

    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    _weatherBloc.dispatch(FetchWeather(
        longitude: position.longitude, latitude: position.latitude));
  }

  void _showLocationDeniedDialog(PermissionHandler permissionHandler) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('La localisation est désactivée :(',
                style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Activer!',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                onPressed: () {
                  permissionHandler.openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
