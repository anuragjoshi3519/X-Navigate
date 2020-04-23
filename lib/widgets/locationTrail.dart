import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/locationItem.dart';

class LocationTrail extends StatelessWidget {
  final List<LocationItem> _locationList;
  LocationTrail(this._locationList);
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return Container(
      child: Column(
        children: <Widget>[
          FittedBox(
              child: Text(
            'Real-Time Location Trail',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          )),
          SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      flex: 3,
                      child: const Text('Latitude',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ))),
                  Expanded(
                      flex: 3,
                      child: const Text(
                        'Longitude',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                  Expanded(
                      flex: 4,
                      child: const Text(
                        'TimeStamp',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                ]),
          ),
          SizedBox(
            height: 8.0,
          ),
          Container(
            height: (mediaQuery.size.height - mediaQuery.padding.top) * 0.65,
            child: ListView.builder(
              itemBuilder: (ctx, index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text(
                                '${_locationList[index].position.latitude}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).accentColor,
                                ))),
                        Expanded(
                            flex: 3,
                            child: Text(
                                '${_locationList[index].position.longitude}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).accentColor,
                                ))),
                        Expanded(
                            flex: 4,
                            child: Text(
                                '${DateFormat("dd/MM/yyyy").add_jm().format(_locationList[index].dateTime)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).accentColor,
                                ))),
                      ]),
                );
              },
              itemCount: _locationList.length,
            ),
          ),
        ],
      ),
    );
  }
}
