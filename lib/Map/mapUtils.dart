import 'package:geolocator/geolocator.dart';

Map<String, dynamic> computeCentroid(List<Map<String, dynamic>> points) {
  double latitude = 0;
  double longitude = 0;
  int n = points.length;

  for (Map<String, dynamic> point in points) {
    latitude += point["latitude"];
    longitude += point["longitude"];
  }

  Map<String, dynamic> centroid = Map();
  centroid["latitude"] = latitude / n;
  centroid["longitude"] = longitude / n;

  return centroid;
}