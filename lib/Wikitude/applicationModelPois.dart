import 'dart:math';

import 'package:location/location.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'poi.dart';

class ApplicationModelPois {
  static Future<List<Poi>> prepareApplicationDataModel() async {
    var db = await Db.create("mongodb+srv://js_user:98jDALJkULhygfOQ@hisg.s18sj.mongodb.net/HiSG?retryWrites=true&w=majority");
    await db.open();
    var coll = db.collection("poi");
    List allPoi = await coll.find({}).toList();
    // final Random random = new Random();
    // final int min = 1;
    // final int max = 10;
    // final int placesAmount = 10;
    final Location location = new Location();

    List<Poi> pois = <Poi>[];
    try {
      LocationData userLocation = await location.getLocation();
      for (int i = 0; i < allPoi.length; i++) {
        var poi = allPoi[i];
        pois.add(new Poi(poi._id, poi.geometry.location.lng, poi.geometry.location.lat, poi.vicinity, userLocation.altitude!, poi.name));
      }
    } catch(e) {
      print("Location Error: " + e.toString());
    }
    return pois;
  }
}