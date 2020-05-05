import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../models/locationItem.dart';

class ShowOnMap extends StatefulWidget {
  final List<LocationItem> _locationList;
  ShowOnMap(this._locationList);

  @override
  _ShowOnMapState createState() => _ShowOnMapState();
}

class _ShowOnMapState extends State<ShowOnMap> {
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  MapType _mapType = MapType.normal;

  PolylinePoints polylinePoints = PolylinePoints();

  void setMapPins() {
    var len = widget._locationList.length;
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: LatLng(widget._locationList[0].position.latitude,
              widget._locationList[0].position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange)));
      _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: LatLng(widget._locationList[len - 1].position.latitude,
            widget._locationList[len - 1].position.longitude),
      ));
    });
  }

  void setPolylines() {
    widget._locationList.forEach((LocationItem loc) {
      polylineCoordinates
          .add(LatLng(loc.position.latitude, loc.position.longitude));
    });
    setState(() {
      Polyline polyline = Polyline(
          jointType: JointType.round,
          polylineId: PolylineId('poly'),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);

      _polylines.add(polyline);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    setMapPins();
    setPolylines();
  }

  void _changeMapType(){
    setState(() {
      if(_mapType==MapType.normal){
        _mapType=MapType.satellite;
      }else{
        _mapType = MapType.normal;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var len = widget._locationList.length;
    var lat = widget._locationList[len - 1].position.latitude;
    var lon = widget._locationList[len - 1].position.longitude;
    LatLng _source = LatLng(lat, lon);

    return Stack(children: [
      GoogleMap(
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        compassEnabled: true,
        indoorViewEnabled: true,
        tiltGesturesEnabled: false,
        zoomControlsEnabled: false,
        markers: _markers,
        polylines: _polylines,
        mapType: _mapType,
        initialCameraPosition: CameraPosition(
          target: _source,
          zoom: 17.0,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: FloatingActionButton(
            onPressed: () => _changeMapType(),
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: Colors.green,
            child: const Icon(Icons.map, size: 35.0),
          ),
        ),
      )
    ]);
  }
}
