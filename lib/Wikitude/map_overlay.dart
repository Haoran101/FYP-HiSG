import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:hi_sg/DataSource/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../DataSource/api_key.dart' as api;

final MAPBOX_ACCESS_TOKEN = api.mapbox_access_token;

class MapWidget extends StatefulWidget {
  double? height;
  double? width;
  List<String>? polylines;
  MapWidget({Key? key, this.height, this.width, this.polylines})
      : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<Polyline> polylines = [];

  initState() {
    if (widget.polylines != null) {
      for (final encodedPolyString in widget.polylines!) {
        polylines.add(Polyline(
            points: decodeEncodedPolyline(encodedPolyString),
            color: Color.fromRGBO(255, 0, 117, 1),
            strokeWidth: 3));
      }
    }

    super.initState();
  }

  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = new LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
          Consumer<UserLocation>(builder: (context, UserLocation loc, child) {
        return Container(
          height: widget.height ?? double.infinity,
          width: widget.width ?? double.infinity,
          child: FlutterMap(
            options: MapOptions(
                center: LatLng(loc.latitude, loc.longitude),
                zoom: 18.0,
                plugins: [
                  LocationMarkerPlugin(),
                ]),
            children: [
              TileLayerWidget(
                options: TileLayerOptions(
                  urlTemplate:
                      "https://api.mapbox.com/styles/v1/weih0006/cksha5ahb1lxk17s3siaxqxie/tiles/256/{z}/{x}/{y}@2x?access_token=$MAPBOX_ACCESS_TOKEN",
                  attributionBuilder: (_) {
                    return Text("©Mapbox  ");
                  },
                ),
              ),
              PolylineLayerWidget(
                  options: PolylineLayerOptions(
                polylines: polylines,
              )),
              LocationMarkerLayerWidget(), // <- add layer widget here
            ],
          ),
        );
      }),
    );
  }
}
