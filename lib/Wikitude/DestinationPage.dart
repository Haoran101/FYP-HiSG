// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hi_sg/DataSource/google_maps_platform.dart';
import 'package:hi_sg/DataSource/location_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:hi_sg/Models/search_result_model.dart';
import 'package:hi_sg/SearchResults/detail_page_container.dart';
import 'package:hi_sg/UI/CommonWidget.dart';
import 'package:hi_sg/UI/navDialog.dart';
import 'package:hi_sg/Wikitude/sample.dart';
import '../DataSource/api_key.dart' as api;
import '../Models/nav_info_model.dart';
import '../SearchResults/poi_details.dart';

// ignore: non_constant_identifier_names
final MAPBOX_ACCESS_TOKEN = api.mapbox_access_token;

// ignore: must_be_immutable
class DestinationPage extends StatefulWidget {
  Sample sample = Sample.fromJson(
    {
      "name": "AR Walking Navigation",
      "path": "01_AR_Navigation_Program/index.html",
      "requiredFeatures": ["geo"],
      "required_extensions": ["native_detail", "application_model_pois"],
      "startupConfiguration": {
        "camera_position": "back",
        "camera_resolution": "auto"
      }
    },
  );
  NavInfo? destination;
  DestinationPage({this.destination});

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  LatLng? _center;
  LatLng? _currentPos;
  String? _currentSearchTerm;
  LatLngBounds? _mapBounds;
  List<Location> _resultList = [];
  LocationService locationService = LocationService();

  final destinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentSearchTerm = null;
    _mapBounds = null;
  }

  @override
  void dispose() {
    destinController.dispose();
    super.dispose();
  }

  Future<Position?> ensureLocationFetched() async {
    await locationService.fetchUserPosition();
    
    return locationService.position;
  }

  updateLocation(pos) async {
    setState(() {
      _currentPos = pos;
      _center = pos;
    });
  }

  searchPlaces() async {
    if (destinController.text != "") {
      print(
          "current search term: ${_currentSearchTerm ?? destinController.text}");
      setState(() {
        _currentSearchTerm = destinController.text;
      });
      var resultList = await PlaceApiProvider().getGooglePlaceListByTextSearch(
          _currentSearchTerm ?? destinController.text);
      if (resultList != null && resultList.length > 0) {
        //results fetched. display result cards
        setState(() {
          _resultList = List.generate(resultList.length,
              (index) => Location.fromJSON(resultList[index], index));
        });
      } else {
        //show failed to fetch result dialog
        UI.showCustomSnackBarMessage(context, "No results found for : "+ _currentSearchTerm.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search For Destination'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.search, size: 32),
          onPressed: searchPlaces,
        ),
      ),
      body: FutureBuilder(
          future: ensureLocationFetched(),
          builder: (context, AsyncSnapshot<Position?> snapshot) {
            if (snapshot.hasError) {
              return UI.errorMessage();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 900,
                child: Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                ),
              );
            }

            var pos = LatLng(snapshot.data!.latitude, snapshot.data!.longitude);

            if (_center == null) {
              WidgetsBinding.instance
                  ?.addPostFrameCallback((_) => updateLocation(pos));
            }

            return SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 100,
                    child: Form(
                      child: Column(
                        children: [
                          FromRow(),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: Row(
                              children: [
                                Container(
                                    child: Text(
                                  "To",
                                  style: TextStyle(fontSize: 17),
                                )),
                                Spacer(),
                                Container(
                                  height: 40,
                                  width:
                                      MediaQuery.of(context).size.width - 150,
                                  child: TextField(
                                    controller: destinController,
                                    decoration: InputDecoration(
                                      labelText: "Enter your destination",
                                      border: OutlineInputBorder(),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        _currentSearchTerm =
                                            destinController.text;
                                      });
                                      searchPlaces();
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                MapAndPageView(pos: pos, resultList: _resultList)
              ]),
            );
          }),
    );
  }
}

class MapAndPageView extends StatefulWidget {
  const MapAndPageView({
    Key? key,
    required this.pos,
    required List<Location> resultList,
  })  : _resultList = resultList,
        super(key: key);

  final LatLng pos;
  final List<Location> _resultList;

  @override
  State<MapAndPageView> createState() => _MapAndPageViewState();
}

class _MapAndPageViewState extends State<MapAndPageView> {
  LatLng? _center;
  LatLng? pos;
  LatLngBounds? _mapBounds;
  CustomPageView? pageView;
  int? pageNumber;

  @override
  void initState() {
    _center = this.widget._resultList.length > 0
        ? this.widget._resultList[0].location
        : this.widget.pos;
    pos = this.widget.pos;
    pageView = CustomPageView(
      callback: updateCenter,
      resultList: this.widget._resultList,
    );
    super.initState();
  }

  updateCenter(number) {
    print("called");
    print(number);
    setState(() {
      this._center = this.widget._resultList[number].location;
      this._mapBounds = this.widget._resultList[number].bounds;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool emptyList = this.widget._resultList.length == 0;

    print("Center: $_center");

    return Stack(children: [
      Container(
        height: MediaQuery.of(context).size.height - 140,
        child: FlutterMap(
          key: UniqueKey(),
          options: MapOptions(
            center: this._center,
            bounds: this._mapBounds,
            zoom: 14.0,
            minZoom: 5.0,
            maxZoom: 20.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate:
                  "https://api.mapbox.com/styles/v1/weih0006/cksha5ahb1lxk17s3siaxqxie/tiles/256/{z}/{x}/{y}@2x?access_token=$MAPBOX_ACCESS_TOKEN",
              attributionBuilder: (_) {
                return Text("©Mapbox  ");
              },
            ),
            MarkerLayerOptions(
              markers: [
                Marker(
                  point: this._center!,
                  builder: (ctx) => Container(
                    child: Center(
                        child: InkWell(
                            onTap: () => print("taped marker"),
                            child:
                                Icon(Icons.place, color: Colors.red, size: 50))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Opacity(opacity: emptyList ? 0 : 0.8, child: pageView),
    ]);
  }
}

// ignore: must_be_immutable
class CustomPageView extends StatelessWidget with ChangeNotifier {
  List? resultList;
  int pageNumber = 0;
  Function callback;
  CustomPageView({this.resultList, required this.callback});

  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 140,
      padding: EdgeInsets.only(top: 450, bottom: 100),
      child: PageView(
          controller: pageController,
          children: List.generate(this.resultList!.length,
              (index) => LocationCard(this.resultList![index])),
          onPageChanged: (int) {
            pageNumber = int;
            print(int);
            callback(int);
          }),
    );
  }
}

class FromRow extends StatelessWidget {
  const FromRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            child: Text(
          "From",
          style: TextStyle(fontSize: 17),
        )),
        Spacer(),
        Container(
          height: 40,
          width: MediaQuery.of(context).size.width - 150,
          child: TextField(
              enabled: false,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Current location",
                border: OutlineInputBorder(),
              )),
        ),
        SizedBox(
          width: 30,
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class LocationCard extends StatelessWidget {
  Location? loc;

  LocationCard(
    Location this.loc,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        height: 100,
        width: MediaQuery.of(context).size.width - 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0, bottom: 10),
                      child: Text(
                        this.loc!.name!,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      this.loc!.type!,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Center(child: Text(this.loc!.locality!)),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 5, right: 5),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.push(
                        context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPageContainer(searchResult: loc!.toSearchResult(),)),
                      ),
                      icon: Icon(Icons.info, size: 35, color: Colors.blue)),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      NavInfo dest = NavInfo(
                          name: this.loc!.name,
                          lat: this.loc!.location!.latitude,
                          lon: this.loc!.location!.longitude,
                          place_id: this.loc!.placeId);
                      showNavigationDialog(context, dest);
                    },
                    icon: Icon(Icons.near_me, size: 35, color: Colors.red[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Location {
  LatLng? location;
  LatLngBounds? bounds;
  String? name;
  String? locality;
  String? type;
  String? placeId;
  int? index;
  Map<String, dynamic>? details;

  Location.fromJSON(jsonObject, index) {
    index = index;
    name = jsonObject["name"];
    location = LatLng(jsonObject["geometry"]["location"]["lat"],
        jsonObject["geometry"]["location"]["lng"]);
    bounds = LatLngBounds(
        LatLng(jsonObject["geometry"]["viewport"]["northeast"]["lat"],
            jsonObject["geometry"]["viewport"]["northeast"]["lng"]),
        LatLng(jsonObject["geometry"]["viewport"]["southwest"]["lat"],
            jsonObject["geometry"]["viewport"]["southwest"]["lng"]));
    placeId = jsonObject["place_id"];
    var typeImportant = searchImportantGoogleType(jsonObject["types"]);
    type = typeImportant.replaceAll("_", " ").toUpperCase();
    locality = jsonObject["vicinity"];
    details = jsonObject;
  }

  toSearchResult(){
    return SearchResult.fromGoogle(this.details!);
  }
}
