import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../DataSource/location_provider.dart';

class ARNavigationOverlay extends StatefulWidget {
  ARNavigationOverlay({Key? key, this.navData});
  RouteData? navData;

  @override
  State<ARNavigationOverlay> createState() => _ARNavigationOverlayState();
}

class _ARNavigationOverlayState extends State<ARNavigationOverlay> {
  int currentId = 0;

  Widget? _instruction;

  Widget? _distance;

  Widget? _duration;

  double _currDistance = -1;

  double _currDuration = -1;

  RouteData? _navData;

  @override
  void initState() {
    _navData = widget.navData;
    super.initState();
  }

  switchToNext() {
    if (currentId + 1 < _navData!.route!.length){
      Future.delayed(Duration(milliseconds: 20), () async {
        setState(()  {
        currentId += 1;
      });});
      print(_navData!.route![currentId].instruction!);
      print(currentId.toString() + "/" + _navData!.route!.length.toString());
    } else {
      showReturnDialog();
    }
  }


  @override
  Widget build(context) {
    return Consumer<UserLocation>(
      builder: (context, UserLocation loc, child) {
      if (_navData == null) return SizedBox();
      _currDistance = _calculateDistance(loc.latitude, loc.longitude,
          _navData!.route![currentId].lat, _navData!.route![currentId].lon);
      _currDuration = _currDistance / _navData!.route![currentId].speed!;
      if (_currDistance < 5 && _currDistance >= 0) {
        switchToNext();}
      return Stack(children: [
        DistanceWidget(currDistance: _currDistance),
        InstructionWidget(navData: _navData, currentId: currentId),
        DurationWidget(currDuration: _currDuration),
        Center(child: TextButton(
          child: Text("Next"),
          onPressed: () => switchToNext()),)
      ]);} );
  }

  _calculateDistance(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = _deg2rad(lat2 - lat1); // deg2rad below
    var dLon = _deg2rad(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c * 1000; // Distance in km
    return d;
  }

  _deg2rad(deg) {
    return deg * (pi / 180);
  }

  Widget get instruction {
    return _instruction!;
  }

  Widget get distance {
    return _distance!;
  }

  Widget get duration {
    return _duration!;
  }

  showReturnDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("Congrats!"),
              content: Text(
                  "You have arrived at your destination! Please exit the AR mode."),
              actions: [
                //Confirm button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    "Exit",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ]);
        });
  }
}

class DurationWidget extends StatelessWidget {
  const DurationWidget({
    Key? key,
    required double currDuration,
  })  : _currDuration = currDuration,
        super(key: key);

  final double _currDuration;

  @override
  Widget build(BuildContext context) {
    print(_currDuration);
    return Positioned(
      bottom: 100,
      right: 60,
      child: Container(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            Icons.timer_outlined,
            color: Colors.black,
            size: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _currDuration / 60 < 60
                  ? (_currDuration / 60).toStringAsFixed(0) + " min"
                  : (_currDuration / 3600).toStringAsFixed(1) + " h",
              style: TextStyle(fontSize: 22),
            ),
          ),
        ]),
      ),
    );
  }
}

class DistanceWidget extends StatelessWidget {
  const DistanceWidget({
    Key? key,
    required double currDistance,
  })  : _currDistance = currDistance,
        super(key: key);

  final double _currDistance;

  @override
  Widget build(BuildContext context) {
    print(_currDistance);
    return Positioned(
      bottom: 100,
      left: 80,
      child: Container(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            Icons.directions_walk_rounded,
            color: Colors.black,
            size: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _currDistance < 1000
                  ? _currDistance.toStringAsFixed(1) + " m"
                  : (_currDistance / 1000).toStringAsFixed(2) + " km",
              style: TextStyle(fontSize: 22),
            ),
          ),
        ]),
      ),
    );
  }
}

class InstructionWidget extends StatelessWidget {
  const InstructionWidget({
    Key? key,
    required RouteData? navData,
    required this.currentId,
  })  : _navData = navData,
        super(key: key);

  final RouteData? _navData;
  final int currentId;

  @override
  
  Widget build(BuildContext context) {
    print(currentId);
    return Positioned(
      top: 5,
      child: Html(
        data: "<div>" + _navData!.route![currentId].instruction! + "</div>",
        style: {
          "div": Style(
              fontSize: FontSize(18),
              textAlign: TextAlign.center,
              lineHeight: LineHeight(1.5))
        },
      ),
    );
  }
}

class RouteData {
  double? startLat;
  double? endLat;
  double? startLon;
  double? endLon;
  List<RoutePoint>? route;

  RouteData.fromJSON(jsonObject) {
    this.startLat = jsonObject["startLat"];
    this.endLat = jsonObject["endLat"];
    this.startLon = jsonObject["startLon"];
    this.endLon = jsonObject["endLon"];
    this.route = List.generate(jsonObject["path"].length, (index) {
      var curr = jsonObject["path"][index];
      return RoutePoint(
          id: curr["id"],
          lat: curr["latitude"],
          lon: curr["longitude"],
          instruction: curr["instruction"],
          distance: double.parse(curr["distance"].toString()),
          speed: curr["speed"] == null
              ? 1.3
              : double.parse(curr["speed"].toString()),
          duration: double.parse(curr["duration"].toString()));
    });
  }
}

class RoutePoint {
  int? id;
  double? lat;
  double? lon;
  String? instruction;
  double? distance;
  double? speed;
  double? duration;

  RoutePoint(
      {Key? key,
      required int this.id,
      required double this.lat,
      required double this.lon,
      required String this.instruction,
      required double this.distance,
      required double this.speed,
      required double this.duration});
}
