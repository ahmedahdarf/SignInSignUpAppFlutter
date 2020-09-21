import 'package:flutter/material.dart';
import 'package:pfa_project_cloudhpc/model/weather.dart';
import 'package:pfa_project_cloudhpc/utils/converters.dart';
import 'package:pfa_project_cloudhpc/widgets/value_tile.dart';

/// Renders Weather Icon, current, min and max temperatures
class CurrentConditions extends StatelessWidget {
  final Weather weather;
  const CurrentConditions({Key key, this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          weather.getIconData(),
          size: 70,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          '${this.weather.temperature.as(TemperatureUnit.celsius).round()}°',
          style: TextStyle(fontSize: 70, fontWeight: FontWeight.w100),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          ValueTile("max",
              '${this.weather.maxTemperature.as(TemperatureUnit.celsius).round()}°'),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Center(
                child: Container(
              width: 1,
              height: 30,
            )),
          ),
          ValueTile("min",
              '${this.weather.minTemperature.as(TemperatureUnit.celsius).round()}°'),
        ]),
      ],
    );
  }
}
