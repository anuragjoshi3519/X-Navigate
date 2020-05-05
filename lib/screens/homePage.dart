import 'dart:io';

import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/locationTrail.dart';
import '../models/locationItem.dart';
import './showOnMap.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<LocationItem> _locationList = [];
  Position _currentPosition;
  bool _isPermissionGiven = true;
  bool _showMap = false;

  final _addMessage = const SnackBar(
      elevation: 2,
      behavior: SnackBarBehavior.fixed,
      content: Text(
        'Manually adding new location entry...',
      ),
      duration: Duration(milliseconds: 900));
  final _downloadMessage = const SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Text(
        'Downloading CSV file...',
      ),
      duration: Duration(seconds: 3));

  final _nothingDownloaded = const SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Text(
        'Sorry! No data available for downloading.',
      ),
      duration: Duration(seconds: 3));

  final _successMessage = const SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Text(
        'File downloaded to Download folder.',
      ),
      duration: Duration(seconds: 3));

  final _failedMessage = const SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Text(
        'Download failed..',
      ),
      duration: Duration(seconds: 3));

  final _turnOnLocation = const SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Text(
        'Please turn on location.',
      ),
      duration: Duration(seconds: 2));

  void _checkLocationPermission() async {
    bool isAvailable = await Geolocator().isLocationServiceEnabled();
    setState(() {
      _isPermissionGiven = isAvailable;
    });
  }

  void _handleShowMapSwitch(val) {
    setState(() {
      _showMap = val;
    });
  }

  void _getLocationListCSV(context) async {
    if (_locationList.isEmpty) {
      Scaffold.of(context).showSnackBar(_nothingDownloaded);
      return;
    }

    Scaffold.of(context).showSnackBar(_downloadMessage);
    List<List<dynamic>> rows = List<List<dynamic>>();
    List<dynamic> row = List();
    row.add('latitude');
    row.add('longitude');
    row.add('timestamp');
    rows.add(row);
    for (int i = 0; i < _locationList.length; i++) {
      List<dynamic> row = List();
      row.add(_locationList[i].position.latitude);
      row.add(_locationList[i].position.longitude);
      row.add(_locationList[i].dateTime.millisecondsSinceEpoch);
      rows.add(row);
    }
    //final String dir = (await getExternalStorageDirectory()).path;
    final String path = '/storage/emulated/0/Download';
    final File file = File(path + '/locations.csv');
    //print(file);
    String csv = const ListToCsvConverter().convert(rows);

    final PermissionHandler _permissionHandler = PermissionHandler();
    var result =
        await _permissionHandler.requestPermissions([PermissionGroup.storage]);
    if (result[PermissionGroup.storage] == PermissionStatus.granted) {
      file.writeAsString(csv);
      Scaffold.of(context).showSnackBar(_successMessage);
    } else {
      Scaffold.of(context).showSnackBar(_failedMessage);
    }
  }

  void _getLocationStream(context) {
    if (_isPermissionGiven) {
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      var locationOptions = LocationOptions(
          accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 1);
      geolocator.getPositionStream(locationOptions).listen((Position pos) {
        setState(() {
          _currentPosition = pos;
          _locationList.insert(
              0, LocationItem(position: pos, dateTime: DateTime.now()));
        });
      });
    } else {
      Scaffold.of(context).showSnackBar(_turnOnLocation);
    }
  }

  void _getCurrentLocation(context) {
    if (_locationList.isNotEmpty && _isPermissionGiven) {
      Scaffold.of(context).showSnackBar(_addMessage);
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(
              desiredAccuracy: LocationAccuracy.bestForNavigation)
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
    if (!_isPermissionGiven) {
      Scaffold.of(context).showSnackBar(_turnOnLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkLocationPermission();
    return Scaffold(
      backgroundColor: _showMap ? Colors.grey[200] : Colors.white,
      appBar: AppBar(
        title: const Text('X-Navigate'),
        centerTitle: true,
        actions: <Widget>[
          Builder(
            builder: (ctx) {
              return IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: () => _getLocationListCSV(ctx),
              );
            },
          ),
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
                                    color: Theme.of(context).errorColor,
                                    fontSize: 16))),
                      ),
                    if (_showMap == false)
                      _currentPosition == null
                          ? FittedBox(
                              child: Builder(
                                builder: (ctx) {
                                  return RaisedButton(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(20.0),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        "Start Location Trail",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.5),
                                      ),
                                    ),
                                    onPressed: () => _getLocationStream(ctx),
                                  );
                                },
                              ),
                            )
                          : LocationTrail(_locationList),
                  ],
                ),
              ),
              if (_showMap)
                Container(
                  height: 600,
                  child: ShowOnMap(_locationList.reversed.toList()),
                ),
            ],
          ),
        ),
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
        if(_currentPosition!=null)
        Builder(builder: (ctx) {
        return FloatingActionButton(
            backgroundColor: Colors.green,
            child: !_showMap? const Icon(Icons.location_on,size: 25): const Icon(Icons.arrow_back,size: 30,),
            onPressed: !_showMap? () => _handleShowMapSwitch(true):() =>_handleShowMapSwitch(false));
      }),
      SizedBox(height:10),
        Builder(builder: (ctx) {
        return FloatingActionButton(
            backgroundColor: Colors.blueGrey,
            child: const Icon(Icons.add),
            onPressed: () => _getCurrentLocation(ctx));
      })
      ],),
    );
  }
}
