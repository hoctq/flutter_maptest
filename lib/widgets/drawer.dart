import 'package:flutter/material.dart';
import 'package:flutter_maptest/pages/center_fab_example.dart';
import 'package:flutter_maptest/pages/home.dart';
import 'package:flutter_maptest/pages/home2.dart';
import 'package:flutter_maptest/pages/live_location.dart';
import 'package:flutter_maptest/pages/polyline.dart';
import 'package:flutter_maptest/pages/timer/timer.dart';

Widget _buildMenuItem(
    BuildContext context, Widget title, String routeName, String currentRoute) {
  final isSelected = routeName == currentRoute;

  return ListTile(
    title: title,
    selected: isSelected,
    onTap: () {
      if (isSelected) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, routeName);
      }
    },
  );
}

Drawer buildDrawer(BuildContext context, String currentRoute) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        const DrawerHeader(
          child: Center(
            child: Text('Flutter Map Examples'),
          ),
        ),
        _buildMenuItem(
          context,
          const Text('timer'),
          TimerPage.route,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('maker'),
          CenterFabExample.route,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Home'),
          Home.route,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Polylines'),
          PolylinePage.route,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Live Location'),
          LiveLocationPage.route,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Trong anh'),
          HomePage.route,
          currentRoute,
        )
      ],
    ),
  );
}
