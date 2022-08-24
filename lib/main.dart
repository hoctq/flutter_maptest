// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_maptest/pages/center_fab_example.dart';
import 'package:flutter_maptest/pages/home.dart';
import 'package:flutter_maptest/pages/live_location.dart';
import 'package:flutter_maptest/pages/polyline.dart';
import 'package:flutter_maptest/pages/timer/timer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
      routes: <String, WidgetBuilder>{
        PolylinePage.route: (context) => const PolylinePage(),
        LiveLocationPage.route: (context) => const LiveLocationPage(),
        CenterFabExample.route: (context) => CenterFabExample(),
        TimerPage.route: (context) => const TimerPage()
      },
    );
  }
}
