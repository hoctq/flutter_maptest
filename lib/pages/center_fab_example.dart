import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_maptest/pages/timer/bloc/timer_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../constants/polyline_data.dart';
import '../widgets/drawer.dart';
import 'timer/ticker.dart';

class CenterFabExample extends StatefulWidget {
  static const String route = '/center_fab_example';
  @override
  _CenterFabExampleState createState() => _CenterFabExampleState();
}

class _CenterFabExampleState extends State<CenterFabExample> {
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double?> _centerCurrentLocationStreamController;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _centerCurrentLocationStreamController = StreamController<double?>();
  }

  @override
  void dispose() {
    _centerCurrentLocationStreamController.close();
    super.dispose();
  }

  void dragMap() {
    setState(
      () => _centerOnLocationUpdate = CenterOnLocationUpdate.never,
    );
    print(_centerOnLocationUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Center FAB Example'),
      ),
      drawer: buildDrawer(context, CenterFabExample.route),
      body: BlocProvider(
        create: (_) => TimerBloc(ticker: const Ticker()),
        child: Stack(fit: StackFit.expand, children: [
          LiveMap(
            centerCurrentLocationStreamController:
                _centerCurrentLocationStreamController.stream,
            centerOnLocationUpdate: _centerOnLocationUpdate,
            onUserDragMap: dragMap,
          ),
          Positioned(
            left: 20,
            top: 20,
            child: FloatingActionButton(
              heroTag: 'center_locate',
              onPressed: () {
                // Automatically center the location marker on the map when location updated until user interact with the map.
                setState(
                  () => _centerOnLocationUpdate = CenterOnLocationUpdate.always,
                );
                // Center the location marker on the map and zoom the map to level 18.
                _centerCurrentLocationStreamController.add(18);
              },
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.5,
            builder: ((context, scrollController) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const MyWidget())),
          ),
          _MapFabs(),
        ]),
      ),
    );
  }

  Widget mapbox() {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(0, 0),
        zoom: 5,
        maxZoom: 19,
        // Stop centering the location marker on the map if user interacted with the map.
        onPositionChanged: (MapPosition position, bool hasGesture) {
          // if (state is TimerRunInProgress) {
          //   print('heheheh');
          // }
          if (hasGesture) {
            setState(
              () => _centerOnLocationUpdate = CenterOnLocationUpdate.never,
            );
          }
        },
      ),
      // ignore: sort_child_properties_last
      children: [
        TileLayerWidget(
          options: TileLayerOptions(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/khtntt/cl70oljur002o15lac6it39ek/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia2h0bnR0IiwiYSI6ImNsNzBtaDV6aTBmanIzcHIxeG9rbTB0NmoifQ.XiZPYyo_f7n1Jkp6cOGn_A",
            additionalOptions: const {
              'accessToken':
                  'pk.eyJ1Ijoia2h0bnR0IiwiYSI6ImNsNzBtaDV6aTBmanIzcHIxeG9rbTB0NmoifQ.XiZPYyo_f7n1Jkp6cOGn_A',
              'id': 'mapbox.mapbox-bathymetry-v2'
            },
            maxZoom: 19,
          ),
        ),
        LocationMarkerLayerWidget(
          plugin: LocationMarkerPlugin(
            centerCurrentLocationStream:
                _centerCurrentLocationStreamController.stream,
            centerOnLocationUpdate: _centerOnLocationUpdate,
          ),
        ),
      ],
      layers: [
        PolylineLayerOptions(polylines: getPolylines(context)),
      ],
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

late Future<List<Polyline>> polylines;

List<Polyline> getPolylines(BuildContext context) {
  List<LatLng> point = []; //
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

class LiveMap extends StatelessWidget {
  // const LiveMap({super.key});
  final Stream<double?> centerCurrentLocationStreamController;
  final CenterOnLocationUpdate centerOnLocationUpdate;
  final VoidCallback onUserDragMap;

  const LiveMap({
    required this.centerCurrentLocationStreamController,
    required this.centerOnLocationUpdate,
    required this.onUserDragMap,
  });

  @override
  Widget build(BuildContext context) {
    final point = context.select((TimerBloc bloc) => bloc.state.positionPoint);
    return FlutterMap(
      options: MapOptions(
          zoom: 5,
          maxZoom: 19,
          onPositionChanged: (MapPosition position, bool hasGesture) {
            if (hasGesture) {
              onUserDragMap;
            }
          }),
      // ignore: sort_child_properties_last
      children: [
        TileLayerWidget(
          options: TileLayerOptions(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/khtntt/cl70oljur002o15lac6it39ek/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia2h0bnR0IiwiYSI6ImNsNzBtaDV6aTBmanIzcHIxeG9rbTB0NmoifQ.XiZPYyo_f7n1Jkp6cOGn_A",
            additionalOptions: const {
              'accessToken':
                  'pk.eyJ1Ijoia2h0bnR0IiwiYSI6ImNsNzBtaDV6aTBmanIzcHIxeG9rbTB0NmoifQ.XiZPYyo_f7n1Jkp6cOGn_A',
              'id': 'mapbox.mapbox-bathymetry-v2'
            },
            maxZoom: 19,
          ),
        ),
        LocationMarkerLayerWidget(
          plugin: LocationMarkerPlugin(
            centerCurrentLocationStream: centerCurrentLocationStreamController,
            centerOnLocationUpdate: centerOnLocationUpdate,
          ),
        ),
      ],
      layers: [
        PolylineLayerOptions(polylines: [
          Polyline(
            points: point,
            strokeWidth: 4,
            color: Colors.amber,
          ),
        ]),
        PolylineLayerOptions(polylines: getPolylines(context)),
      ],
    );
  }
}

class TimerText1 extends StatelessWidget {
  const TimerText1({super.key});

  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final minutesStr =
        ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).toString().padLeft(2, '0');
    return Text('$minutesStr:$secondsStr',
        style: const TextStyle(fontSize: 20));
  }
}

class DistanceText extends StatelessWidget {
  const DistanceText({super.key});

  @override
  Widget build(BuildContext context) {
    final distance = context.select((TimerBloc bloc) => bloc.state.distance);
    return Text('$distance', style: const TextStyle(fontSize: 20));
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, state) {
          return Container(
            color: Colors.white,
            height: 70,
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: const [
                          Text('Time'),
                          TimerText1(),
                        ],
                      ),
                      Column(
                        children: const [
                          Text('Distance'),
                          DistanceText(),
                        ],
                      ),
                      Column(
                        children: const [
                          Text('Elevation gain'),
                          Text(
                            '00:00',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      )
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: const [
                          Text('Remianing time'),
                          Text(
                            '00:00',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: const [
                          Text('Avg. pace'),
                          Text(
                            '00:00',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: const [
                          Text('Avg. speed'),
                          Text(
                            '00:00',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      )
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(5)),
                          child: const Icon(
                            Icons.add,
                            size: 50,
                          ),
                          onPressed: () => {}),
                      if (state is TimerInitial) ...[
                        ElevatedButton(
                          onPressed: () => context.read<TimerBloc>().add(
                              TimerStarted(
                                  duration: state.duration,
                                  positionPoint: state.positionPoint,
                                  distance: state.distance)),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 100),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            'Start',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                      if (state is TimerRunInProgress) ...[
                        ElevatedButton(
                          onPressed: () => context
                              .read<TimerBloc>()
                              .add(const TimerPaused()),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 100),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            'Pause',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<TimerBloc>().add(const TimerReset()),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 100),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                      if (state is TimerRunPause) ...[
                        ElevatedButton(
                          onPressed: () => context
                              .read<TimerBloc>()
                              .add(const TimerResumed()),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 100),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            'Resumed',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<TimerBloc>().add(const TimerReset()),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 100),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                      if (state is TimerRunComplete) ...[
                        ElevatedButton(
                          onPressed: () =>
                              context.read<TimerBloc>().add(const TimerReset()),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 100),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(5)),
                        child: const Icon(
                          Icons.add,
                          size: 50,
                        ),
                        onPressed: () {},
                      ),
                    ]),
              ],
            ),
          );
        });
  }
}

class _MapFabs extends StatelessWidget {
  // final bool visible;
  // final VoidCallback onAddPlacePressed;
  // final VoidCallback onToggleMapTypePressed;

  // const _MapFabs({
  // required this.visible,
  // required this.onAddPlacePressed,
  // required this.onToggleMapTypePressed,
  // });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.only(top: 12.0, right: 12.0),
      child: Visibility(
        visible: true,
        child: Column(
          children: [
            FloatingActionButton(
              heroTag: 'add_place_button',
              onPressed: () => {},
              materialTapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: Colors.green,
              child: const Icon(Icons.add_location, size: 36.0),
            ),
            const SizedBox(height: 12.0),
            FloatingActionButton(
              heroTag: 'toggle_map_type_button',
              onPressed: () => {},
              materialTapTargetSize: MaterialTapTargetSize.padded,
              mini: true,
              backgroundColor: Colors.green,
              child: const Icon(Icons.layers, size: 28.0),
            ),
          ],
        ),
      ),
    );
  }
}
