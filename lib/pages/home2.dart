import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../widgets/drawer.dart';

class HomePage extends StatefulWidget {
  static const String route = '/home2';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Location location = Location();

  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  final markers = <Marker>[];

  Future lo() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    markers.add(
      Marker(
        width: 20,
        height: 20,
        point: LatLng(
            _locationData?.latitude ?? 0.0, _locationData?.longitude ?? 0.0),
        builder: (ctx) => const Icon(
          Icons.circle,
          color: Colors.red,
        ),
      ),
    );
    setState(() {});

    location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        _points
            .add(LatLng(currentLocation.latitude!, currentLocation.longitude!));
      }
      // setState(() {});
    });
  }

  final _points = <LatLng>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await lo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: buildDrawer(context, HomePage.route),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: Text('This is a map that is showing (51.5, -0.9).'),
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(_locationData?.latitude ?? 0.0,
                      _locationData?.longitude ?? 0.0),
                  zoom: 15,
                  plugins: [
                    const LocationMarkerPlugin(
                      centerOnLocationUpdate: CenterOnLocationUpdate.always,
                      turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
                    ),
                  ],
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        // 'mapbox://styles/anhht/cl6xsjdjr002c14o29kznfeqq',
                        'https://api.mapbox.com/styles/v1/anhht/cl6vy0ebm005w14p43q9tawnu/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYW5oaHQiLCJhIjoiY2w2dnh4YTZnMjhvZjNkbnp3enhxY25heiJ9._R4zPu-MPsc-y1uuFPCLEQ',
                    // subdomains: ['a', 'b', 'c'],
                    // userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                    // additionalOptions: {
                    //   "access_token":
                    //       "pk.eyJ1IjoiYW5oaHQiLCJhIjoiY2w2dnh4YTZnMjhvZjNkbnp3enhxY25heiJ9._R4zPu-MPsc-y1uuFPCLEQ"
                    // },
                  ),
                  PolylineLayerOptions(
                    polylines: [
                      Polyline(
                          points: _points,
                          strokeWidth: 4,
                          color: Colors.purple),
                    ],
                  ),
                  MarkerLayerOptions(markers: markers),
                  LocationMarkerLayerOptions(
                    marker: const DefaultLocationMarker(
                      child: Icon(
                        Icons.navigation,
                        color: Colors.white,
                      ),
                    ),
                    markerSize: const Size(40, 40),
                    markerDirection: MarkerDirection.heading,
                  ),
                ],
                nonRotatedChildren: [
                  AttributionWidget.defaultWidget(
                    source: 'Mapbox',
                    onSourceTapped: () {},
                    alignment: Alignment.bottomLeft,
                  ),
                  AttributionWidget(
                    attributionBuilder: (context) => Container(
                      width: 10,
                      height: 10,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
