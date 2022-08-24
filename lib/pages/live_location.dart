import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_maptest/widgets/drawer.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LiveLocationPage extends StatefulWidget {
  static const String route = '/live_location';

  const LiveLocationPage({Key? key}) : super(key: key);

  @override
  _LiveLocationPageState createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> {
  LocationData? _currentLocation;
  late final MapController _mapController;
  List<LatLng> point = [];

  final bool _liveUpdate = true;
  bool _permission = false;

  String? _serviceError = '';

  int interActiveFlags = InteractiveFlag.all;

  final Location _locationService = Location();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    initLocationService();
  }

  void initLocationService() async {
    await _locationService.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 10,
    );

    LocationData? location;
    bool serviceEnabled;
    bool serviceRequestResult;

    int quangduong = 0;

    try {
      serviceEnabled = await _locationService.serviceEnabled();

      if (serviceEnabled) {
        final permission = await _locationService.requestPermission();
        _permission = permission == PermissionStatus.granted;

        if (_permission) {
          location = await _locationService.getLocation();
          _currentLocation = location;
          _locationService.onLocationChanged
              .listen((LocationData result) async {
            if (mounted) {
              setState(() {
                _currentLocation = result;
                // print(
                // "do cao ${_currentLocation!.altitude}, toc do ${_currentLocation!.speed}, toc do accury${_currentLocation!.speedAccuracy}, time ${DateTime.fromMillisecondsSinceEpoch(_currentLocation!.time!.toInt())} time2 ${_currentLocation!.time!}");
                point.add(
                  LatLng(_currentLocation!.latitude!.toDouble(),
                      _currentLocation!.longitude!.toDouble()),
                );
                // If Live Update is enabled, move map center
                if (_liveUpdate) {
                  _mapController.move(
                      LatLng(_currentLocation!.latitude!,
                          _currentLocation!.longitude!),
                      _mapController.zoom);
                }
              });
            }
          });
        }
      } else {
        serviceRequestResult = await _locationService.requestService();
        if (serviceRequestResult) {
          initLocationService();
          return;
        }
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      if (e.code == 'PERMISSION_DENIED') {
        _serviceError = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        _serviceError = e.message;
      }
      location = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng currentLatLng;

    // Until currentLocation is initially updated, Widget can locate to 0, 0
    // by default or store previous location value to show.
    if (_currentLocation != null) {
      currentLatLng =
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    } else {
      currentLatLng = LatLng(0, 0);
    }

    final markers = <Marker>[
      Marker(
          width: 80,
          height: 80,
          point: currentLatLng,
          builder: (ctx) => const Icon(Icons.location_on)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: buildDrawer(context, LiveLocationPage.route),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: _serviceError!.isEmpty
                  ? Text('This is a map that is showing '
                      '(${currentLatLng.latitude}, ${currentLatLng.longitude}).')
                  : Text(
                      'Error occured while acquiring location. Error Message : '
                      '$_serviceError'),
            ),
            // Flexible(
            //   child: FlutterMap(
            //     mapController: _mapController,
            //     options: MapOptions(
            //       center:
            //           LatLng(currentLatLng.latitude, currentLatLng.longitude),
            //       zoom: 15,
            //       interactiveFlags: interActiveFlags,
            //     ),
            //     children: [
            //       TileLayer(
            //         // urlTemplate:
            //         //     'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            //         // subdomains: ['a', 'b', 'c'],
            //         // userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            //         urlTemplate:
            //             "https://api.mapbox.com/styles/v1/khtntt/cl70oljur002o15lac6it39ek/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia2h0bnR0IiwiYSI6ImNsNzBtaDV6aTBmanIzcHIxeG9rbTB0NmoifQ.XiZPYyo_f7n1Jkp6cOGn_A",
            //         additionalOptions: const {
            //           'accessToken':
            //               'pk.eyJ1Ijoia2h0bnR0IiwiYSI6ImNsNzBtaDV6aTBmanIzcHIxeG9rbTB0NmoifQ.XiZPYyo_f7n1Jkp6cOGn_A',
            //           'id': 'mapbox.mapbox-bathymetry-v2'
            //         },
            //       ),
            //       MarkerLayer(markers: markers),
            //       PolylineLayer(
            //         polylines: [
            //           Polyline(
            //               points: point, strokeWidth: 4, color: Colors.purple),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
      // floatingActionButton: Builder(builder: (BuildContext context) {
      //   return FloatingActionButton(
      //     onPressed: () {
      //       setState(() {
      //         _liveUpdate = !_liveUpdate;

      //         if (_liveUpdate) {
      //           interActiveFlags = InteractiveFlag.rotate |
      //               InteractiveFlag.pinchZoom |
      //               InteractiveFlag.doubleTapZoom;

      //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //             content: Text(
      //                 'In live update mode only zoom and rotation are enable'),
      //           ));
      //         } else {
      //           interActiveFlags = InteractiveFlag.all;
      //         }
      //       });
      //     },
      //     child: _liveUpdate
      //         ? const Icon(Icons.location_on)
      //         : const Icon(Icons.location_off),
      //   );
      // }),
    );
  }
}
