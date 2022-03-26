import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Currency/currency_home.dart';
import 'package:wikitude_flutter_app/DataSource/google_maps_platform.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/SearchResults/detail_page_container.dart';
import 'package:wikitude_flutter_app/SearchResults/poi_details.dart';

import '../DataSource/location_provider.dart';

var _floatStyle = TextStyle(
    letterSpacing: 2.2,
    color: Colors.white,
    fontFamily: "Montserrat",
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.bold,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(1.0, 1.0),
        blurRadius: 3.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
    ]);

var _imageFilterOpacity = 0.7;

class EmptySearchScreen extends StatefulWidget {
  const EmptySearchScreen({Key? key}) : super(key: key);

  @override
  State<EmptySearchScreen> createState() => _EmptySearchScreenState();
}

class _EmptySearchScreenState extends State<EmptySearchScreen> {
  List<SearchResult>? nearbyList;
  final locationService = LocationService();

  @override
  void initState() {
    this.nearbyList = locationService.nearbyList;
    super.initState();
  }

  fetchGoogleNearbyResult() async {
    if (this.nearbyList != null) {
      print("nearby List fetched from cache.");
      return this.nearbyList;
    }
    var pos = await LocationService().fetchUserPosition();
    print("Position returned: " + pos.toString());
    var resultListRaw = await PlaceApiProvider().getGoogleNearbyResult(
        LocationService().latitute, LocationService().longitude);
    this.nearbyList = [];
    for (var map in resultListRaw!) {
      if (map["types"].contains("point_of_interest") &&
          map.containsKey("photos")) {
        this.nearbyList!.add(SearchResult.fromGoogle(map));
      }
    }
    locationService.setNearbyList = this.nearbyList;
    return this.nearbyList;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 80,
              ),
              Banner(
                  text: "360 GALLERY",
                  image: "assets/img/explore/singapore.jpg",
                  nextPage: null),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  HalfBanner(
                      text: "PRECINCT",
                      image: "assets/img/explore/chinatown.jpg",
                      color: Colors.red[900]!,
                      nextPage: null),
                  Spacer(),
                  HalfBanner(
                      text: "WALKING\n  TRAIL",
                      image: "assets/img/explore/walking.jpg",
                      color: Colors.green,
                      nextPage: null),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  HalfBanner(
                      text: "TRANSPORT",
                      image: "assets/img/explore/mrt.jpg",
                      color: Colors.blueAccent,
                      nextPage: null),
                  Spacer(),
                  HalfBanner(
                      text: "CURRENCY",
                      image: "assets/img/explore/money.jpg",
                      color: Colors.deepOrangeAccent,
                      nextPage: CurrencyConverterScreen())
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Nearby Spots",
                  style: TextStyle(fontSize: 20, color: Colors.black87),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: 150,
                  child: FutureBuilder(
                      future: fetchGoogleNearbyResult(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          print(snapshot.stackTrace);
                          return Text("Error loading nearby results");
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ListView(
                            scrollDirection: Axis.horizontal,
                            children:
                                List.generate(this.nearbyList!.length, (index) {
                              SearchResult curr = this.nearbyList![index];
                              String? photoReference =
                                  curr.details!["photos"] == null
                                      ? null
                                      : curr.details!["photos"][0]
                                          ["photo_reference"];
                              return InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DetailPageContainer(
                                                  searchResult: curr))),
                                  child: NearbySpotBlock(
                                      photoReference: photoReference,
                                      curr: curr));
                            }));
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NearbySpotBlock extends StatelessWidget {
  const NearbySpotBlock({
    Key? key,
    required this.photoReference,
    required this.curr,
  }) : super(key: key);

  final String? photoReference;
  final SearchResult curr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Container(
          width: 180,
          color: Colors.black54,
          child: Stack(children: [
            Opacity(
              opacity: 0.5,
              child: GoogleImage(
                photoRef: photoReference,
                cover: true,
              ),
            ),
            Column(children: [
              Spacer(),
              Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Text(
                      curr.subtitle ?? "",
                      style: TextStyle(color: Colors.yellow, fontSize: 12),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    curr.title,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              )
            ]),
          ])),
    );
  }
}

class Banner extends StatelessWidget {
  Banner({required this.text, required this.image, required this.nextPage});
  final String text;
  final String image;
  final Widget? nextPage;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          print("called on $text");
          if (this.nextPage != null){
            Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => this.nextPage!),);
          } else {
            print("not implemented");
          }
          
        },
        child: Container(
          child: Stack(alignment: Alignment.center, children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xff7c94b6),
                  image: new DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(_imageFilterOpacity),
                          BlendMode.dstATop),
                      image: new AssetImage(
                        this.image,
                      )),
                ),
              ),
            ),
            Text(
              this.text,
              style: _floatStyle.copyWith(fontSize: 25),
            ),
          ]),
        ));
  }
}

class HalfBanner extends StatelessWidget {
  HalfBanner(
      {required this.text,
      required this.image,
      required this.color,
      required this.nextPage});
  final String text;
  final String image;
  final Color color;
  final Widget? nextPage;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          print("called on $text");
          if (this.nextPage != null){
            Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => this.nextPage!),);
          } else {
            print("not implemented");
          }},
        child: Container(
          child: Stack(alignment: Alignment.center, children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                width: 170,
                height: 100,
                decoration: BoxDecoration(
                  color: color,
                  image: new DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(_imageFilterOpacity),
                          BlendMode.dstATop),
                      image: new AssetImage(
                        this.image,
                      )),
                ),
              ),
            ),
            Text(
              this.text,
              style: _floatStyle.copyWith(fontSize: 15),
            ),
          ]),
    ));
  }
}
