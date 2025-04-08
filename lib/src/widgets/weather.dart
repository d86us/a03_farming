import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  WeatherState createState() => WeatherState();
}

class WeatherState extends State<Weather> {
  dynamic _weatherData;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      final result = results.first;
      if (result == ConnectivityResult.none) {
        setState(() {
          _weatherData = 'No internet connection';
        });
      } else {
        _loadWeatherData();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _weatherData = 'No internet connection';
      });
      return;
    }
    final url =
        'https://www.meteosource.com/api/v1/free/point?place_id=nairobi&sections=current%2Cdaily&language=en&units=auto&key=6apezn3zxdhhuso8zyqnup0rdsm39cjunovgf72w';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _weatherData = jsonData;
        });
      } else {
        if (kDebugMode) {
          print('Failed to load data: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: _weatherData is String
              ? Text(
                  _weatherData,
                  style: TextStyle(fontSize: 18),
                )
              : _weatherData == null
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.black),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Table(
                          columnWidths: {
                            0: FlexColumnWidth(
                                2), // Make the first column twice as wide as the second column
                          },
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_weatherData['timezone'].split('/').length > 1 ? _weatherData['timezone'].split('/')[1] : _weatherData['timezone']} ${_weatherData['current']['temperature'].round()}°C',
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      Text(
                                        'High: ${_weatherData['daily']['data'][0]['all_day']['temperature_max'].round()}°C, Low: ${_weatherData['daily']['data'][0]['all_day']['temperature_min'].round()}°C',
                                      ),
                                    ],
                                  ),
                                ),
                                TableCell(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Image.asset(
                                        'assets/images/weather_icons/${_weatherData['current']['icon_num']}.png',
                                        width: 60,
                                        height: 60),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10), // Add some space before the table
                        _buildTemperatureTable(),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildTemperatureTable() {
    List<String> daysOfWeek = [];
    List<String> highTemperatures = [];
    List<String> lowTemperatures = [];
    List<Widget> weatherIcons = [];

    for (var day in _weatherData['daily']['data'].skip(1).take(5)) {
      String date = _getDayOfWeek(day['day']);
      daysOfWeek.add(date);
      String highTemperature =
          '${(day['all_day']['temperature_max'] as num).round()}°C';
      highTemperatures.add(highTemperature);
      String lowTemperature =
          '${(day['all_day']['temperature_min'] as num).round()}°C';
      lowTemperatures.add(lowTemperature);
      int iconNum = day['all_day']['icon'];
      weatherIcons.add(Image.asset('assets/images/weather_icons/${iconNum}.png',
          width: 24, height: 24));
    }

    return Row(
      children: daysOfWeek.map((day) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      day,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: weatherIcons[daysOfWeek.indexOf(day)],
                  ),
                  Center(
                    child: Text(highTemperatures[daysOfWeek.indexOf(day)]),
                  ),
                  Center(
                    child: Text(lowTemperatures[daysOfWeek.indexOf(day)]),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getDayOfWeek(String date) {
    DateTime dateTime = DateTime.parse(date);
    List<String> daysOfWeek = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return daysOfWeek[dateTime.weekday % 7];
  }
}
