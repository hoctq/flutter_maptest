import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_maptest/pages/home.dart';
import 'package:flutter_maptest/pages/live_location.dart';
import 'package:flutter_maptest/pages/polyline.dart';

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
        )
      ],
    ),
  );
}
