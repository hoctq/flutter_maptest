import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_maptest/constants/define.dart';
import 'package:flutter_maptest/widgets/drawer.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

class Home extends StatelessWidget {
  static const String route = '/';

  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: buildDrawer(context, route),
      body: FlutterMap(
        options: MapOptions(
          center: lat_lng.LatLng(51.509364, -0.128928),
          zoom: 14,
          onTap: (tapPosition, point) => print(point),
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/khtntt/cl70oljur002o15lac6it39ek/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia2h0bnR0IiwiYSI6ImNsNzBtaDV6aTBmanIzcHIxeG9rbTB0NmoifQ.XiZPYyo_f7n1Jkp6cOGn_A",
            additionalOptions: const {
              'accessToken':
                  Strings.pk_mapbox_access_token,
              'id': 'mapbox.mapbox-bathymetry-v2'
            },
          ),
        ],
      ),
    );
  }
}
