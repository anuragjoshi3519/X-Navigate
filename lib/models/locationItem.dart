import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

class LocationItem{
  final Position position;
  final DateTime dateTime;
  LocationItem({@required this.position,@required this.dateTime});
}