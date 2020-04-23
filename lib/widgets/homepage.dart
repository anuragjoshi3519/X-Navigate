import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/locationTrail.dart';
import '../models/locationItem.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<LocationItem> _locationList = [];
  Position _currentPosition;
  bool _isPermissionGiven = true;

  void _checkLocationPermission() async {
    bool isAvailable = await Geolocator().isLocationServiceEnabled();
    setState(() {
      _isPermissionGiven = isAvailable;
    });
  }

  void _getLocationStream() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 1);
    geolocator.getPositionStream(locationOptions).listen((Position pos) {
      setState(() {
        _currentPosition = pos;
        _locationList.insert(
            0, LocationItem(position: pos, dateTime: DateTime.now()));
      });
    });
  }

  void _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
        .then((Position pos) {
      setState(() {
        _currentPosition = pos;
        _locationList.insert(
            0, LocationItem(position: pos, dateTime: DateTime.now()));
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    _checkLocationPermission();
    return Scaffold(
      appBar: AppBar(
        title: Text('X-Navigate'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _getCurrentLocation(),
          )
        ],
      ),
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    if (!_isPermissionGiven)
                      Container(
                        padding: EdgeInsets.all(6.0),
                        margin: EdgeInsets.only(bottom: 6.0),
                        child: FittedBox(
                            child: Text('Please turn on location.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.red[800], fontSize: 16))),
                      ),
                    _currentPosition == null
                        ? FittedBox(
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0),
                              ),
                              color: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const Text(
                                  "Start Location Trail",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18.5),
                                ),
                              ),
                              onPressed: () => _getLocationStream(),
                            ),
                          )
                        : LocationTrail(_locationList),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueGrey,
          child: Icon(Icons.add),
          onPressed: () =>
              _currentPosition != null ? _getCurrentLocation() : null),
    );
  }
}
