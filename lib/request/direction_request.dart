import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_maptest/constants/define.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:latlong2/latlong.dart' as lat;

String baseUrl = 'https://api.mapbox.com/directions/v5/mapbox';
String accessToken = Strings.pk_mapbox_access_token;
String navType = 'cycling';

Dio _dio = Dio();

Future getCyclingRouteUsingMapbox(lat.LatLng from, lat.LatLng to) async {
  debugPrint(accessToken);
  String url =
      // '$baseUrl/$navType/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?alternatives=true&continue_straight=true&geometries=geojson&language=en&overview=full&steps=true&access_token=$accessToken';
      '$baseUrl/$navType/-84.518641,39.134270;-84.512023,39.102779?alternatives=true&continue_straight=true&geometries=geojson&language=en&overview=full&steps=true&access_token=$accessToken';
      print(url);
  try {
    _dio.options.contentType = Headers.jsonContentType;
    final responseData = await _dio.get(url);
    return responseData.data;
  } catch (e) {
    debugPrint(e.toString());
  }
}
