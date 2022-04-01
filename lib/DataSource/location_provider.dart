import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:hi_sg/Models/search_result_model.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.

class LocationService {
  // Keep track of current Location
  static final LocationService _instance = LocationService._internal();
  factory LocationService({Key? key}) => _instance;

  LocationService._internal() {
    _currentLocation = null;
    _nearbyList = null;

    location.requestPermission().then((granted) {
      if (granted == PermissionStatus.granted) {
        location.onLocationChanged.listen((locationData) {
          if (locationData != null) {
            _locationController.add(UserLocation(
              latitude: locationData.latitude!,
              longitude: locationData.longitude!,
            ));
          }
        });
      }
    });
  }

  UserLocation? _currentLocation;
  List<SearchResult>? _nearbyList;
  Location location = Location();
  // Continuously emit location updates
  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>.broadcast();

  Stream<UserLocation> get locationStream => _locationController.stream;

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      this._currentLocation = UserLocation(
        latitude: userLocation.latitude!,
        longitude: userLocation.longitude!,
      );
    } catch (e) {
      print('Could not get the location: $e');
    }
    return this._currentLocation!;
  }

  double? get latitute {
    if (this._currentLocation != null) {
      return this._currentLocation!.latitude;
    } else {
      print("failed to load location");
      return null;
    }
  }

  double? get longitude {
    if (this._currentLocation != null) {
      return this._currentLocation!.longitude;
    } else {
      print("failed to load location");
      return null;
    }
  }

  List<SearchResult>? get nearbyList {
    if (this._nearbyList == null)
      return null;
    else
      return _nearbyList;
  }

  set setNearbyList(List<SearchResult>? inputList) {
    this._nearbyList = inputList;
  }
}

class UserLocation {
  final double latitude;
  final double longitude;
  UserLocation({required this.latitude, required this.longitude});
}
