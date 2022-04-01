import 'package:augmented_reality_plugin_wikitude/wikitude_plugin.dart';
import 'package:augmented_reality_plugin_wikitude/wikitude_response.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hi_sg/Models/nav_info_model.dart';
import 'package:hi_sg/Wikitude/arview.dart';
import 'package:hi_sg/Wikitude/sample.dart';

// ignore: non_constant_identifier_names
Sample ARNavigation = Sample.fromJson({
  "name": "AR Walking Navigation",
  "path": "01_AR_navigation/index.html",
  "requiredFeatures": ["geo"],
  "required_extensions": ["native_detail", "application_model_pois"],
  "startupConfiguration": {
    "camera_position": "back",
    "camera_resolution": "auto"
  }
});

class NavigationDialog extends StatefulWidget {
  final NavInfo destination;
  final bool fromAnotherARView;
  const NavigationDialog({Key? key, required this.destination, required this.fromAnotherARView})
      : super(key: key);

  @override
  State<NavigationDialog> createState() => _NavigationDialogState();
}

class _NavigationDialogState extends State<NavigationDialog> {
  Future<WikitudeResponse> _requestARPermissions(List<String> features) async {
    return await WikitudePlugin.requestARPermissions(features);
  }

  void _showPermissionError(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Permissions required"),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Open settings'),
                onPressed: () {
                  Navigator.of(context).pop();
                  WikitudePlugin.openAppSettings();
                },
              )
            ],
          );
        });
  }

  Future<void> pushArView() async {
    WikitudeResponse permissionsResponse =
        await _requestARPermissions(ARNavigation.requiredFeatures);
    if (permissionsResponse.success) {
      
      if (widget.fromAnotherARView){
        Navigator.of(context).pop(true);
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ArViewWidget(
                  sample: ARNavigation,
                  destinationNavInfo: widget.destination,
                )),
      );
      } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ArViewWidget(
                  sample: ARNavigation,
                  destinationNavInfo: widget.destination,
                )),
      );}
    } else {
      _showPermissionError(permissionsResponse.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        Container(
          child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Start Your Journey To",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )),
        ),
        this.widget.destination.name == null
            ? Container(
              child: Center(
                  child: Text(
                    "Location: ${widget.destination.lat} , ${widget.destination.lon}",
                    softWrap: true,
                  ),
                ),
            )
            : Container(
              child: Center(
                  child: Text(
                  "${widget.destination.name}",
                  softWrap: true,
                )),
            ),
        //open AR navigation
        Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).primaryColor),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white)),
                    child: Text(
                      "AR Walking Navigation",
                      style: TextStyle(fontSize: 15),
                    ),
                    onPressed: () {
                      //Open AR Navigation
                      pushArView();
                    }))),
        //Open in Google Maps
        Container(
            margin: EdgeInsets.only(top: 10.0),
            child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white)),
                    child: Row(children: [
                      Spacer(),
                      Text(
                        "Open in Google Maps",
                        style: TextStyle(fontSize: 15),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.open_in_new,
                          color: Colors.white,
                        ),
                      ),
                      Spacer()
                    ]),
                    onPressed: () {
                      //Open Google Maps
                      var parameters = [];
                      if (widget.destination.place_id != null) {
                        parameters.add(
                            "destination_place_id=${widget.destination.place_id}");
                      }
                      parameters.add(
                          "destination=${widget.destination.lat},${widget.destination.lon}");

                      String url =
                          "https://www.google.com/maps/dir/?api=1&${parameters.join("&")}";
                      launch(url);
                    }))),
      ]),
      actions: <Widget>[
        //Cancel button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "Close",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

showNavigationDialog(context, NavInfo destination, {bool fromAnotherARView = false}) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return NavigationDialog(destination: destination, fromAnotherARView: fromAnotherARView);
      });
}
