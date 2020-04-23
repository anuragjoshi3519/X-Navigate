import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/homepage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'X-Navigate',
      theme: ThemeData(
        //brightness: Brightness.light,
        primarySwatch: Colors.green,
        accentColor: Colors.blueGrey[900],
      ),
      home: HomePage(),
    );
  }
}
