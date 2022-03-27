// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wikitude_flutter_app/DataSource/tih_data_provider.dart';
import 'package:wikitude_flutter_app/Models/tih_model.dart';
import 'package:wikitude_flutter_app/UI/CommonWidget.dart';
import 'package:latlong2/latlong.dart';
import 'package:wikitude_flutter_app/UI/navDialog.dart';
import '../DataSource/api_key.dart' as api;
import '../Models/nav_info_model.dart';

final MAPBOX_ACCESS_TOKEN = api.mapbox_access_token;

class WalkingTrailDetailsSubpage extends StatefulWidget {
  Map<String, dynamic>? details;
  WalkingTrailDetailsSubpage({Key? key, required this.details})
      : super(key: key);

  @override
  State<WalkingTrailDetailsSubpage> createState() =>
      _WalkingTrailDetailsSubpageState();
}

class _WalkingTrailDetailsSubpageState
    extends State<WalkingTrailDetailsSubpage> {
  TIHDetails? walkingTrail;

  @override
  void initState() {
    this.walkingTrail = TIHDetails.fromWalkingTrailJSON(widget.details!);
    super.initState();
  }

  fetchWalkingTrailDetails() async {
    var uuid = widget.details!["uuid"];
    var details = await TIHDataProvider().getWalkingTrailDetailsByUUID(uuid);
    this.walkingTrail!.setMapTiles(details!);
    print(this.walkingTrail!.walkingTrailPoints);
    return this.walkingTrail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: fetchWalkingTrailDetails(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          print(snapshot.stackTrace);
          return Text("has error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(children: [
          Header(walkingTrail: walkingTrail),
          DefaultTabController(
            length: 2,
            child: SingleChildScrollView(
                child: Column(children: [
              Container(
                margin: EdgeInsets.only(top: 30),
                color: Theme.of(context).primaryColor,
                child: TabBar(
                  tabs: [
                    Tab(text: "Map"),
                    Tab(text: "Description"),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height - 340,
                child: TabBarView(
                  children: [
                    WalkingTrailMapView(
                        mapTiles: this.walkingTrail!.walkingTrailPoints!),
                    DescriptionView(walkingTrail: this.walkingTrail!,)
                  ],
                ),
              ),
            ])),
          ),
        ]);
      },
    ));
  }
}

class DescriptionView extends StatelessWidget {
  
  DescriptionView({Key? key, required this.walkingTrail}) : super(key: key);

  final TIHDetails walkingTrail;

  Widget parseHTML(String? data) {
      return Html(
        data: "<body>" +
            data!.replaceAll("<br>", "<br><br>").replaceAll("</br>", "<br><br>") +
            "</body>",
        onLinkTap: (url, context, attributes, element) {
          launch(url!);
        },
        style: {
          "body": Style(
            fontSize: FontSize(16),
            lineHeight: LineHeight(1.5),
            whiteSpace: WhiteSpace.NORMAL,
          ),
        },
      );
    }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(children: [
          //image
          UI.tihImageBanner(
              width: MediaQuery.of(context).size.width,
              height: 200,
              tihDetails: walkingTrail),
          ///description
                  ///Description Title
                  walkingTrail.description != null && walkingTrail.description != ""
                      ? Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Description",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold))),
                        )
                      : SizedBox(
                          height: 0,
                        ),

                  ///Description Content
                  walkingTrail.description != null && walkingTrail.description != ""
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: walkingTrail.description!.contains(">")
                              ? parseHTML(walkingTrail.description)
                              : Text(
                                  walkingTrail.description!,
                                  style: TextStyle(fontSize: 16, height: 1.5),
                                ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 20,
                  ),

                  ///body
                  ///body Title
                  walkingTrail.body != null &&
                          walkingTrail.body != walkingTrail.description &&
                          walkingTrail.body != ""
                      ? Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Details",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold))),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  //html content
                  walkingTrail.body != null &&
                          walkingTrail.body != walkingTrail.description &&
                          walkingTrail.body != ""
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: walkingTrail.body!.contains(">")
                              ? parseHTML(walkingTrail.body)
                              : Text(
                                  walkingTrail.body!,
                                  style: TextStyle(fontSize: 16, height: 1.5),
                                ),
                        )
                      : SizedBox.shrink(),
          
        ]),
      ),
    );
  }
}

class WalkingTrailMapView extends StatefulWidget {
  List<MapTile> mapTiles;
  WalkingTrailMapView({Key? key, required this.mapTiles}) : super(key: key);

  @override
  State<WalkingTrailMapView> createState() => _WalkingTrailMapViewState();
}

class _WalkingTrailMapViewState extends State<WalkingTrailMapView> {
  LatLng? _center;
  LatLngBounds? _bounds;
  CustomizedMarker? markerSelected;
  final PopupController _popupLayerController = PopupController();

  void initState() {
    this._center =
        computeCentroid(widget.mapTiles.map((p) => p.location!).toList());
    this._bounds =
        boundsFromLatLngList(widget.mapTiles.map((p) => p.location!).toList());
    super.initState();
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0 = -300, x1 = -300, y0 = -300, y1 = -300;
    for (LatLng latLng in list) {
      if (x0 == -300) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(LatLng(x1, y1), LatLng(x0, y0));
  }

  LatLng computeCentroid(List<LatLng> points) {
    double latitude = 0;
    double longitude = 0;
    int n = points.length;

    for (LatLng point in points) {
      latitude += point.latitude;
      longitude += point.longitude;
    }

    LatLng centroid = LatLng(latitude / n, longitude / n);
    return centroid;
  }

  List<Marker> markerRenderer(List<MapTile> maptileList) {
    return maptileList.map((point) => CustomizedMarker(pt: point)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        child: FlutterMap(
          options: MapOptions(
            center: _center,
            bounds: _bounds,
            minZoom: 5.0,
            maxZoom: 20.0,
            interactiveFlags: InteractiveFlag.all,
            onTap: (_, __) => _popupLayerController.hideAllPopups(),
          ),
          children: [
            TileLayerWidget(
              options: TileLayerOptions(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/weih0006/cksha5ahb1lxk17s3siaxqxie/tiles/256/{z}/{x}/{y}@2x?access_token=${MAPBOX_ACCESS_TOKEN}",
                attributionBuilder: (_) {
                  return Align(
                      alignment: Alignment.bottomLeft,
                      child: Text("©Mapbox  "));
                },
              ),
            ),
            PopupMarkerLayerWidget(
              options: PopupMarkerLayerOptions(
                markers: markerRenderer(widget.mapTiles),
                popupController: _popupLayerController,
                popupBuilder: (_, Marker marker) {
                  if (marker is CustomizedMarker) {
                    markerSelected = marker;
                    return CustomizedMarkerPopup(pt: marker.pt);
                  }
                  return SizedBox.shrink();
                },
              ),
            )
          ],
        ),
      ),
    ]);
  }
}

class CustomizedMarker extends Marker {
  CustomizedMarker({required this.pt})
      : super(
          height: 40,
          width: 40,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          point: LatLng(
            pt.location!.latitude,
            pt.location!.longitude,
          ),
          builder: (BuildContext ctx) {
            return Icon(Icons.place, color: Colors.red, size: 40);
          },
        );

  final MapTile pt;
}

class CustomizedMarkerPopup extends StatelessWidget {
  const CustomizedMarkerPopup({Key? key, required this.pt}) : super(key: key);
  final MapTile pt;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          minHeight: 100, minWidth: 200, maxWidth: 200, maxHeight: 400),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                pt.name!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                pt.address!,
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () => showNavigationDialog(
                    context,
                    new NavInfo(
                        name: pt.name,
                        lat: pt.location!.latitude,
                        lon: pt.location!.longitude)),
                child: Icon(Icons.near_me, size: 40, color: Colors.red[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    Key? key,
    required this.walkingTrail,
  }) : super(key: key);

  final TIHDetails? walkingTrail;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      Column(children: [
        //Title
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(walkingTrail!.name!,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
        ),

        //walkingTrail and walkingTrail type
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                      text: "WALKING TRAIL",
                      style: TextStyle(
                          fontSize: 15, color: Theme.of(context).primaryColor),
                      children: [
                        WidgetSpan(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                              margin: EdgeInsets.only(left: 10),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.0),
                                child: Text(walkingTrail!.type!,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white)),
                              )),
                        )
                      ]),
                )))
      ]),
    ]));
  }
}
