import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
///
class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService({Key? key}) => _instance;

  LocationService._internal() {
    _lastFetchLocationTime = null;
    _userPosition = null;
  }

  DateTime? _lastFetchLocationTime;
  Position? _userPosition;
  List<SearchResult>? _nearbyList;

  double? get latitute {
    if (_userPosition != null){
      return _userPosition!.latitude;
    }  else {
      print("failed to load location");
      return null;}
  }

  double? get longitude {
    if (_userPosition != null){
      return _userPosition!.longitude;
    } else 
    {
      print("failed to load location");
      return null;}
  }

  Position? get position {
    if (_userPosition != null){
      return _userPosition;
    } else {
      print("failed to load location");
      return null;}
  }

  List<SearchResult>? get nearbyList {
    if (this._nearbyList == null) return null;
    else return _nearbyList;
  }

  set setNearbyList(List<SearchResult>? inputList) {
    this._nearbyList = inputList;
  }

  periodFetchLocation(int timeIntervalSeconds) {
    if (_lastFetchLocationTime == null) {
      fetchUserPosition();
      print(
          "Fetching user location, last time: null, next time in $timeIntervalSeconds Seconds");
      return;
    }
    DateTime now = DateTime.now();
    print("Now: $now");
    if (now.difference(this._lastFetchLocationTime!).inSeconds >
        timeIntervalSeconds) {
      print(
          "Fetching user location, last time ${_lastFetchLocationTime!.toIso8601String()}, next time in $timeIntervalSeconds Seconds");
      fetchUserPosition();
    }
  }

  fetchUserPosition() async {
    print("fetchUserPosition called");
    if (this._userPosition!= null){
      return this._userPosition;
    }
    var pos = await determinePosition();
    print(pos);
    this._userPosition = pos;
    this._lastFetchLocationTime = DateTime.now();
    return pos;
  }

  Future<Position> determinePosition() async {
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

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

}
