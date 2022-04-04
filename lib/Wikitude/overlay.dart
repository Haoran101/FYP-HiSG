import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hi_sg/MicroServices/compass.dart';
import 'package:provider/provider.dart';

import '../DataSource/location_provider.dart';

class ARNavigationOverlay extends StatefulWidget {
  ARNavigationOverlay({Key? key, this.navData, this.isLightMode});
  RouteData? navData;
  bool? isLightMode = true;

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

  Color? _textColor;

  @override
  void initState() {
    _navData = widget.navData;
    bool light = widget.isLightMode ?? true;
    _textColor = light ? Colors.white : Colors.black;
    super.initState();
  }

  void didUpdateWidget(oldWidget) {
    bool light = widget.isLightMode ?? true;
    _textColor = light ? Colors.white : Colors.black;
    super.didUpdateWidget(oldWidget);
  }

  switchToNext() {
    try {
      var nextIndex = currentId + 1;
      while (nextIndex < _navData!.route!.length - 1) {
        var distance = _navData!.route![nextIndex].distance;
        if (distance! < 40) {
          nextIndex += 1;
        } else {
          break;
        }
      }

      if (nextIndex >= _navData!.route!.length - 1) {
        showReturnDialog();
      } else {
        Future.delayed(Duration(milliseconds: 200), () async {
          setState(() {
            currentId = min(nextIndex, _navData!.route!.length - 1);
          });
        });
        print(_navData!.route![currentId].instruction!);
        print(currentId.toString() + "/" + _navData!.route!.length.toString());
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(context) {
    return Consumer<UserLocation>(builder: (context, UserLocation loc, child) {
      if (_navData == null) return SizedBox();
      _currDistance = _calculateDistance(loc.latitude, loc.longitude,
          _navData!.route![currentId].lat, _navData!.route![currentId].lon);
      _currDuration = _currDistance / _navData!.route![currentId].speed!;
      if (_currDistance < 60 && _currDistance >= 0) {
            switchToNext();
      }

      return Stack(children: [
        DistanceWidget(
          currDistance: _currDistance,
          textColor: _textColor!,
        ),
        InstructionWidget(
          navData: _navData,
          currentId: currentId,
          textColor: _textColor!,
        ),
        DurationWidget(
          currDuration: _currDuration,
          textColor: _textColor!,
        ),
        //Next Turn
        Positioned(
            bottom: 180,
            left: 30,
            child: Text(
              "Next Turn",
              style: TextStyle(fontSize: 22, color: _textColor),
            )),
        //Next Button
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton(
              child: Text(
                "Next",
                style: TextStyle(color: _textColor),
              ),
              onPressed: () => switchToNext()),
        )
      ]);
    });
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
    required Color textColor,
  })  : _currDuration = currDuration,
        _textColor = textColor,
        super(key: key);

  final double _currDuration;
  final Color _textColor;

  @override
  Widget build(BuildContext context) {
    print("Color? " + _textColor.toString());
    return Positioned(
      bottom: 100,
      right: 60,
      child: Container(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            Icons.timer_outlined,
            color: _textColor,
            size: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _currDuration / 60 < 60
                  ? (_currDuration / 60).toStringAsFixed(0) + " min"
                  : (_currDuration / 3600).toStringAsFixed(1) + " h",
              style: TextStyle(fontSize: 22, color: _textColor),
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
    required Color textColor,
  })  : _currDistance = currDistance,
        _textColor = textColor,
        super(key: key);

  final double _currDistance;
  final Color _textColor;

  @override
  Widget build(BuildContext context) {
    print(_currDistance);
    return Positioned(
      bottom: 100,
      left: 50,
      child: Container(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            Icons.directions_walk_rounded,
            color: _textColor,
            size: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _currDistance < 1000
                  ? _currDistance.toStringAsFixed(1) + " m"
                  : (_currDistance / 1000).toStringAsFixed(2) + " km",
              style: TextStyle(fontSize: 22, color: _textColor),
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
    required Color textColor,
  })  : _navData = navData,
        _textColor = textColor,
        super(key: key);

  final RouteData? _navData;
  final int currentId;
  final Color _textColor;

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
              color: _textColor,
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
  List<String>? polylines;
  List<RoutePoint>? route;

  RouteData.fromJSON(jsonObject) {
    this.startLat = jsonObject["startLat"];
    this.endLat = jsonObject["endLat"];
    this.startLon = jsonObject["startLon"];
    this.endLon = jsonObject["endLon"];
    this.polylines = List.generate(jsonObject["path"].length, (index) {
      var curr = jsonObject["path"][index];
      return curr["polyline"];
    });
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
