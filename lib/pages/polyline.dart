import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_maptest/constants/polyline_data.dart';
import 'package:flutter_maptest/widgets/drawer.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';

class PolylinePage extends StatefulWidget {
  static const String route = 'polyline';

  const PolylinePage({Key? key}) : super(key: key);

  @override
  State<PolylinePage> createState() => _PolylinePageState();
}

class _PolylinePageState extends State<PolylinePage> {
  late Future<List<Polyline>> polylines;

  Future<List<Polyline>> getPolylines() async {
    List<LatLng> point = [];
    for (int i = 0; i < geojson.length; i++) {
      point.add(LatLng(geojson[i][1], geojson[i][0]));
    }
    final polyLines = [
      Polyline(
        points: point,
        strokeWidth: 4,
        color: Colors.amber,
      ),
    ];
    // await Future<void>.delayed(const Duration(seconds: 3));
    return polyLines;
  }

  @override
  void initState() {
    polylines = getPolylines();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Polylines')),
        drawer: buildDrawer(context, PolylinePage.route),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: FutureBuilder<List<Polyline>>(
            future: polylines,
            builder:
                (BuildContext context, AsyncSnapshot<List<Polyline>> snapshot) {
              debugPrint('snapshot: ${snapshot.hasData}');
              if (snapshot.hasData) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      child: Text('Polylines'),
                    ),
                    Flexible(
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(geojson[0][1], geojson[0][0]),
                          zoom: 13,
                          onTap: (tapPosition, point) {
                            setState(() {
                              debugPrint('onTap');
                            });
                          },
                        ),
                        // children: [
                        //   TileLayer(
                        //     urlTemplate:
                        //         "https://api.mapbox.com/styles/v1/khtntt/cl70oljur002o15lac6it39ek/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia2h0bnR0IiwiYSI6ImNsNzBtaDV6aTBmanIzcHIxeG9rbTB0NmoifQ.XiZPYyo_f7n1Jkp6cOGn_A",
                        //     additionalOptions: const {
                        //       'accessToken':
                        //           'pk.eyJ1Ijoia2h0bnR0IiwiYSI6ImNsNzBtaDV6aTBmanIzcHIxeG9rbTB0NmoifQ.XiZPYyo_f7n1Jkp6cOGn_A',
                        //       'id': 'mapbox.mapbox-bathymetry-v2'
                        //     },
                        //   ),
                        //   PolylineLayer(
                        //     polylines: snapshot.data!,
                        //     polylineCulling: true,
                        //   ),
                        // ],
                      ),
                    ),
                  ],
                );
              }
              return const Text(
                  'Getting map data...\n\nTap on map when complete to refresh map data.');
            },
          ),
        ));
  }
}
