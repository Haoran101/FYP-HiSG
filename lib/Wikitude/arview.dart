import 'dart:async';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hi_sg/DataSource/location_provider.dart';
import 'package:hi_sg/MicroServices/compass.dart';
import 'package:hi_sg/Wikitude/map_overlay.dart';
import 'package:hi_sg/Wikitude/overlay.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:hi_sg/Models/nav_info_model.dart';
import 'package:hi_sg/Models/search_result_model.dart';
import 'package:hi_sg/SearchResults/detail_page_container.dart';
import 'package:hi_sg/UI/navDialog.dart';

import 'sample.dart';

import 'package:path_provider/path_provider.dart';

import 'package:augmented_reality_plugin_wikitude/architect_widget.dart';
import 'package:augmented_reality_plugin_wikitude/wikitude_response.dart';

class ArViewState extends State<ArViewWidget> with WidgetsBindingObserver {
  late ArchitectWidget architectWidget;
  String wikitudeTrialLicenseKey =
      "rRcPFV/GWHOalFjHX9rP9TWGNRKVu8P4FSKvHtps1mo14SexXUmlVAebLNuKKr9OcOFD89RiMH03AY3eJL09d3Pbvb/V+AVYsQiBROkqqAhYe2lDojp++ZAPDx2RM9rJrD+1qYyUUbdUyKzIJXrU09u4tST9NdhER08njP2tMydTYWx0ZWRfX/p90uj/Yn9x/bcRTK6REaUg/GJT6uUKh7KfnXmxAtt0RI9WNjVPQFFjS1WFGtrRI43/VqyS0gnfsjmiov6fyrE+0aGBxJIzBNWupROE+AYw9LFkJ0gRN6KhsqvawIobvSPbVH+OaYanwnIV8q34LyTRujMzvJL+ke0hEfucf6eChYWe3O5kGCRD09oDnBzBLYnZotRjtuDb2eiHksj28kNuHJTlWItLA4A5Xjri7I1FmnCnTYezZfS2EHHazgOwfYAx+RMTSDXkdjrfradWo4kQFlERljYr1fXTh0T9s19r9FJTeao5/4UbUqcAW8mu71LoIQ5i2gJLDEp4d7xBEBaSznQ2TI4DSNW13lGlTXx8Ma47sFk4uxcxNy1S56RC1bPXA/iJGudxQrGMlhrYuwYcbEpKqEAqRB3xCZKV0M/69hlcZTreu3+1LbtYpLBFQ9GGMPC5FMjzVt29UFSVFyChB6PJlfVrpXbyvlq7ZFKWPc77HKIUyVhx5cSuI19pMxoTPiK5FfcuD7NeUJISK2loWzM/Cd5kvjqCZf0mGJ4zs9iwAQrkhpBGr07lwyAKJ0wH4ybZIdFXb69uZHnp9YnibYF6cuq5L+66lNPRicm1ojF46Sc6SkiVeZDfS6J1f2UOL1ymEMi3eH7pc8+AQ5JUn7XJWr8xIcYTlBa4HkJkRV7ire2Daij3cNywrcVv1GuReHLyW+UipWGPKrvY8IONHmkLEuAgdU9WupbmVdt24Cjn2s1n/ecIIKIVm9xgvdd5n4DHXKsOOWY03gp43g/5jgTJdl1PNwaVIvnwC1zMchAL5Ld49im8pcZbYiQC/MQqAdixxpORPZ0i6j0TM86K7P6DgSxmMNP/SG4vDx0m9mxvCIzvyevNl69Rc2yRToAwY1yGHMHyT2LwWr1NDhhW620ALR/u8gycvRhICYmISCwuCEBuSK+2UyKuKHk50gCr+xfLenxYshOJC+3dyGgBKXMkh/T8i0vKIBaKX5LcD0BY+msO4h/vrb4dMB61qzxCuJM8ax6O5tuQc4u5WOi/6XrAIRFTCqLMST8U6JKN689s70FJtvQYm0DpbPfYTOfeA53B5fphfsTMQqXFwKPhVLczCoWftmlLhHb/NcmNmCHnTp/Mm9yObyNsiG3oQ1Wbb1a9eMOcJ5y/Wvpi0RSYGwIfJcIIknvJIwPphZ3AJ3K9x/M89kct/J65XZMAMdnM1FbtLRpgKUVAUIUJ/E6V03QP/ElUHHukYjbXABWs/fJ/6uy9E4aXjbmzJQ6I9VKQ1uUsT2Oh8585HoXp6LLiFxADdRSIllJBtuMCmgfrd06qQ/q9wu8xFzvJYBeIT6xlCbsBXgdm";
  Sample sample;
  String loadPath = "";
  bool loadFailed = false;
  bool navDataLoaded = false;
  NavInfo? destinationJSON;
  LocationService _locationService = LocationService();
  List<Widget> arBody = [];
  RouteData? route;
  bool isARNavigation = false;
  Key navLayerKey = GlobalKey();
  bool? _showMap;
  bool? _showCompass;
  bool? _isWhite;
  bool? _fullScreenMap;

  ArViewState({required this.sample, this.destinationJSON}) {
    if (this.sample.path.contains("http://") ||
        this.sample.path.contains("https://")) {
      loadPath = this.sample.path;
    } else {
      loadPath = "samples/" + this.sample.path;
    }
    isARNavigation = this.sample.name == "AR Walking Navigation";
  }

  @override
  void initState() {
    super.initState();
    _showMap = true;
    _showCompass = true;
    _isWhite = true;
    WidgetsBinding.instance!.addObserver(this);

    architectWidget = new ArchitectWidget(
      onArchitectWidgetCreated: onArchitectWidgetCreated,
      licenseKey: wikitudeTrialLicenseKey,
      startupConfiguration: sample.startupConfiguration,
      features: sample.requiredFeatures,
    );

    this.arBody.add(
          Container(
              decoration: BoxDecoration(color: Colors.black),
              child: architectWidget),
        );

    if (isARNavigation) {
      this.arBody.add(Container(
          color: Colors.black45,
          child: Center(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(255, 0, 117, 1),
            ),
          )));
    }
    Wakelock.enable();
  }

  @override
  void dispose() {
    print("Dispose AR View");
    this.architectWidget.pause();
    this.architectWidget.destroy();
    WidgetsBinding.instance!.removeObserver(this);
    print("Disposed");
    Wakelock.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        this.architectWidget.pause();
        break;
      case AppLifecycleState.resumed:
        this.architectWidget.resume();
        break;
      default:
    }
  }

  List<Widget> getAction() {
    if (isARNavigation) {
      return [
        IconButton(
            onPressed: () => showSwitchControls(), icon: Icon(Icons.settings))
      ];
    } else
      return [];
  }

  printStates() {
    print("showMap: " + this._showMap.toString());
    print("ShowCompass: " + this._showCompass.toString());
    print("isWhite: " + this._isWhite.toString());
  }

  showSwitchControls() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Display Settings"),
            content: StatefulBuilder(builder: (context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.only(right: 20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                    children: [
                      Text("Show Map"),
                      Spacer(),
                      Switch(
                        activeColor: Color.fromRGBO(255, 0, 117, 1),
                        activeTrackColor: Color.fromRGBO(255, 0, 117, 0.5),
                        value: this._showMap!,
                        onChanged: (value) => setState(() {
                          this._showMap = value;
                          changeDisplay();
                          printStates();
                        }),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text("Show Compass"),
                      Spacer(),
                      Switch(
                        activeColor: Color.fromRGBO(255, 0, 117, 1),
                        activeTrackColor: Color.fromRGBO(255, 0, 117, 0.5),
                        value: this._showCompass!,
                        onChanged: (value) => setState(() {
                          this._showCompass = value;
                          changeDisplay();
                          printStates();
                        }),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text("Light Text Color"),
                      Spacer(),
                      Switch(
                        activeColor: Color.fromRGBO(255, 0, 117, 1),
                        activeTrackColor: Color.fromRGBO(255, 0, 117, 0.5),
                        value: this._isWhite!,
                        onChanged: (value) => setState(() {
                          this._isWhite = value;
                          changeDisplay();
                          printStates();
                        }),
                      )
                    ],
                  ),
                ]),
              );
            }),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(255, 0, 117, 1),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          );
        });
  }

  changeDisplay() {
    print("Change display invoked");
    setState(() {
      List<Widget> newARbody = [arBody[0]];

      newARbody.add(Positioned(
        top: 60,
        left: 0,
        height: 130,
        child: Opacity(
          opacity: _showCompass! ? 0.7 : 0,
          child: CompassService(),
        ),
      ));
      newARbody.add(Positioned(
        top: 200,
        right: 10,
        child: Opacity(
          opacity: _showMap! ? 1 : 0,
          child: MapWidget(
            height: 250,
            width: 150,
            polylines: route!.polylines,
          ),
        ),
      ));
      newARbody.add(ARNavigationOverlay(
        key: navLayerKey,
        navData: route,
        isLightMode: _isWhite,
      ));
      arBody = newARbody;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(sample.name),
          backgroundColor: Theme.of(context).primaryColor,
          actions: getAction(),
        ),
        body: WillPopScope(
          onWillPop: () async {
            if (defaultTargetPlatform == TargetPlatform.android &&
                !loadFailed) {
              bool? canWebViewGoBack =
                  await this.architectWidget.canWebViewGoBack();
              if (canWebViewGoBack != null) {
                return !canWebViewGoBack;
              } else {
                return true;
              }
            } else {
              return true;
            }
          },
          child: Stack(children: arBody),
        ));
  }

  Future<void> onArchitectWidgetCreated() async {
    print("Load Path" + this.loadPath);
    this.architectWidget.load(loadPath, onLoadSuccess, onLoadFailed);
    this.architectWidget.resume();

    if ((sample.requiredExtensions.contains("screenshot") ||
        sample.requiredExtensions.contains("save_load_instant_target") ||
        sample.requiredExtensions.contains("native_detail"))) {
      this.architectWidget.setJSONObjectReceivedCallback(onJSONObjectReceived);
    }
  }

  Future<void> onJSONObjectReceived(Map<String, dynamic> jsonObject) async {
    if (jsonObject["action"] != null) {
      switch (jsonObject["action"]) {
        case "capture_screen":
          captureScreen();
          break;

        case "nav_data_loaded":
          Map<String, dynamic> routeData = {
            "startLat": _locationService.latitute!,
            "startLon": _locationService.longitude!,
            "endLat": widget.destinationNavInfo!.lat,
            "endLon": widget.destinationNavInfo!.lon,
            "path": jsonObject["data"]
          };
          RouteData routeLoaded = RouteData.fromJSON(routeData);
          setState(() {
            navDataLoaded = true;
            route = routeLoaded;
            changeDisplay();
          });
          break;
        case "present_poi_details":
          print(jsonObject);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailPageContainer(
                      searchResult: SearchResult.fromGoogle(jsonObject),
                    )),
          );
          break;
        case "poi_navigation":
          print(jsonObject);
          NavInfo nav = NavInfo(
              lat: jsonObject["latitude"],
              lon: jsonObject["longitude"],
              place_id: jsonObject["place_id"],
              name: jsonObject["name"]);
          showNavigationDialog(context, nav, fromAnotherARView: true);
          break;
        case "save_current_instant_target":
          final fileDirectory = await getApplicationDocumentsDirectory();
          final filePath = fileDirectory.path;
          final file = File('$filePath/SavedAugmentations.json');
          file.writeAsString(jsonObject["augmentations"]);
          this.architectWidget.callJavascript(
              "World.saveCurrentInstantTargetToUrl(\"" +
                  filePath +
                  "/SavedInstantTarget.wto" +
                  "\");");
          break;
        case "load_existing_instant_target":
          final fileDirectory = await getApplicationDocumentsDirectory();
          final filePath = fileDirectory.path;
          final file = File('$filePath/SavedAugmentations.json');
          String augmentations;
          try {
            augmentations = await file.readAsString();
          } catch (e) {
            augmentations = "null";
          }
          this.architectWidget.callJavascript(
              "World.loadExistingInstantTargetFromUrl(\"" +
                  filePath +
                  "/SavedInstantTarget.wto" +
                  "\"," +
                  augmentations +
                  ");");
          break;
      }
    }
  }

  Future<void> captureScreen() async {
    WikitudeResponse captureScreenResponse =
        await this.architectWidget.captureScreen(true, "");
    if (captureScreenResponse.success) {
      this.architectWidget.showAlert(
          "Success", "Image saved in: " + captureScreenResponse.message);
    } else {
      if (captureScreenResponse.message.contains("permission")) {
        this
            .architectWidget
            .showAlert("Error", captureScreenResponse.message, true);
      } else {
        this.architectWidget.showAlert("Error", captureScreenResponse.message);
      }
    }
  }

  Future<void> onLoadSuccess() async {
    loadFailed = false;
    if (isARNavigation) {
      this.architectWidget.callJavascript(
          "World.initializeDestination(${_locationService.latitute}, ${_locationService.longitude}, ${this.destinationJSON!.lat}, ${this.destinationJSON!.lon});");
    }
  }

  Future<void> onLoadFailed(String error) async {
    loadFailed = true;
    this.architectWidget.showAlert("Failed to load Architect World", error);
  }
}

// ignore: must_be_immutable
class ArViewWidget extends StatefulWidget {
  final Sample sample;
  NavInfo? destinationNavInfo;

  ArViewWidget({
    Key? key,
    required this.sample,
    this.destinationNavInfo,
  });

  @override
  ArViewState createState() =>
      new ArViewState(sample: sample, destinationJSON: destinationNavInfo);
}
