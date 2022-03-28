import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wikitude_flutter_app/DataSource/cloud_firestore.dart';
import 'package:wikitude_flutter_app/UI/CommonWidget.dart';

import '../DataSource/google_maps_platform.dart';
import '../Models/poi_model.dart';
import 'review_details.dart';

// ignore: must_be_immutable
class POISubPage extends StatefulWidget {
  final placeId;
  final category;
  bool isCid;

  POISubPage({required this.placeId, required this.category, this.isCid = false});

  @override
  _POISubPageState createState() => _POISubPageState();
}

class _POISubPageState extends State<POISubPage> {
  late POI place;
  List imageList = [];
  bool _expanded = false;
  Map<String, dynamic>? hotelData;
  Map<String, dynamic>? mrtData;

  @override
  void initState() {
    super.initState();
  }

  Future fetchPOIDetails() async {
    print(this.widget.isCid);
    if (this.widget.isCid){
      print("cid: " + this.widget.placeId);
      this.place = (await PlaceApiProvider().getPlaceDetailFromCID(widget.placeId))!;
      print("POI details fetched!");
    } else {
      print("place_id: " + this.widget.placeId);
      this.place = (await PlaceApiProvider().getPlaceDetailFromId(widget.placeId))!;
      print("POI details fetched!");
    }
  }

  Future fetchHotelDetails() async {
    if (this.widget.category == "ACCOMMODATION"){
      this.hotelData =
        (await HotelProvider().queryHotelURLByPlaceId(widget.placeId));
      print(this.hotelData);
    }
  }

  Future fetchMRTDetails() async {
    if (this.widget.category == "SUBWAY STATION"){
      this.mrtData =
        (await MRTProvider().fetchMRTDetailsByPlaceId(widget.placeId));
      print(this.mrtData);
    }
  }

  @override
  void dispose() {
    super.dispose();EdgeInsets.all(20.0);
  }

  @override
  Widget build(BuildContext context) {
    var _pageElementPadding = EdgeInsets.all(20.0);

    getPhotoView() {
      if (this.place.photoReferences == null){
        return Container(
          height: 200,
          child: Image.asset("assets/img/placeholder.png", height: 200, width: double.infinity, fit: BoxFit.fitWidth),
        );
      }
      if (this.place.photoReferences!.length < 3) {
        return GoogleImage(photoRef: place.photoReferences![0], cover: true);
      } else {
        return Container(
          height: 200,
          child: ListView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              children: List.generate(
                  place.photoReferences!.length,
                  (index) => GoogleImage(
                      photoRef: place.photoReferences![index], cover: false))),
        );
      }
    }

    return Container(
      child: FutureBuilder(
          future: Future.wait([fetchPOIDetails(), fetchHotelDetails()]),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              print(snapshot.stackTrace);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              //Show circular progress indicator if loading
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //Image scrollable horizontal
                    getPhotoView(),
                    //Title
                    Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 10),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(place.name!,
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold))),
                    ),

                    //Type
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              searchImportantGoogleType(place.types!).toUpperCase().replaceAll("_", " "),
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).primaryColor))),
                    ),

                    //rating bar and direction arrow
                    Padding(
                      padding: _pageElementPadding,
                      child: Row(
                        children: [
                          //rating bar
                          (place.rating == null|| place.rating == -1)
                              ? SizedBox(
                                  width: 10,
                                )
                              : RatingBarIndicator(
                                  rating: place.rating!,
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 30.0,
                                  direction: Axis.horizontal,
                                ),
                          (place.rating == null|| place.rating == -1)
                              ? 
                            SizedBox(width: 0,) :
                            Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              place.rating.toString(),
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Spacer(),
                          //direction button
                          InkWell(
                            child: Icon(Icons.near_me,
                                size: 40, color: Colors.red[400]),
                            onTap: () => print("Tapped direction arrow"),
                            //TODO: navigate to directions page
                          )
                        ],
                      ),
                    ),

                    //hotel button
                    this.hotelData != null
                        ? Padding(
                            padding: EdgeInsets.only(left: 15.0, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).primaryColor),
                                ),
                                icon: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Icon(Icons.open_in_new),
                                ),
                                onPressed: () => launch(this.hotelData!["url"]),
                                label: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text("Book in Google Hotels"),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 0,
                          ),

                    //details info: address, opening hours, phone number, website
                    Container(
                      child: Column(
                        children: [
                          //formatted address
                          place.formattedAddress != null
                              ? ListTile(
                                  leading: Icon(
                                    Icons.location_on_outlined,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(place.formattedAddress!))
                              : SizedBox(
                                  height: 0,
                                ),
                          //open now
                          place.openNow != null
                              ? ExpansionPanelList(
                                  elevation: 0,
                                  animationDuration: Duration.zero,
                                  children: [
                                    ExpansionPanel(
                                      headerBuilder: (context, isExpanded) {
                                        return ListTile(
                                          leading: Icon(
                                            Icons.access_time,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          title: Text(
                                            (place.openNow!)
                                                ? "Open Now"
                                                : "Closed",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        );
                                      },
                                      body: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          physics: BouncingScrollPhysics(),
                                          itemCount: place.openingHour!.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                                leading: SizedBox(),
                                                title: Text(
                                                    place.openingHour![index]));
                                          }),
                                      isExpanded: _expanded,
                                      canTapOnHeader: true,
                                    ),
                                  ],
                                  expansionCallback: (panelIndex, isExpanded) {
                                    setState(() {
                                      _expanded = !_expanded;
                                    });
                                  },
                                )
                              : SizedBox(
                                  height: 0,
                                ),
                          //phone number
                          place.phoneNumber != null
                              ? InkWell(
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.phone,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    title: Text(place.phoneNumber!),
                                  ),
                                  onLongPress: () {
                                    Clipboard.setData(
                                        ClipboardData(text: place.phoneNumber));
                                    UI.showCustomSnackBarMessage(context, "Phone number copied to clipboard.");
                                  },
                                  onTap: () =>
                                      launch("tel://${place.phoneNumber}"),
                                )
                              : SizedBox(
                                  height: 0,
                                ),
                          //website
                          place.website != null
                              ? InkWell(
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.language_outlined,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    title: Text(place.website!),
                                  ),
                                  onLongPress: () {
                                    Clipboard.setData(
                                        ClipboardData(text: place.website));
                                    UI.showCustomSnackBarMessage(context, "Website Url copied to clipboard.");
                                  },
                                  onTap: () => launch("${place.website}"),
                                )
                              : SizedBox(
                                  height: 0,
                                ),
                        ],
                      ),
                    ),

                    //TODO: 360 experiences

                    //reviews
                    place.reviews != null
                        ? Padding(
                            padding: _pageElementPadding,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Reviews",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold))),
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    place.reviews != null
                        ? ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: place.reviews!.length,
                            itemBuilder: (context, index) {
                              var date = DateTime.fromMillisecondsSinceEpoch(
                                  place.reviews![index].timeEpochSeconds! *
                                      1000);
                              var formattedDate =
                                  formatDate(date, [d, ' ', M, ' ', yyyy]);
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ReviewDetailsPage(
                                                  review:
                                                      place.reviews![index]))),
                                  child: ListTile(
                                    leading: Image.network(
                                        place.reviews![index].profilePhotoURL!),
                                    title: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Column(children: [
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(place
                                                .reviews![index].authorName!)),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            formattedDate,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    subtitle: Text(
                                        place.reviews![index].content!.length <
                                                200
                                            ? place.reviews![index].content!
                                            : place.reviews![index].content!
                                                    .substring(0, 200) +
                                                "..."),
                                  ),
                                ),
                              );
                            },
                          )
                        : SizedBox(
                            height: 0,
                          )
                    //TODO: related articles
                    //TODO: Nearby places/events/something
                  ],
                ),
              ),
            );
          }),
    );
  }
}

// ignore: must_be_immutable
class GoogleImage extends StatefulWidget {
  final photoRef;
  bool cover = false;
  GoogleImage({required this.photoRef, required this.cover});

  @override
  _GoogleImageState createState() => _GoogleImageState();
}

class _GoogleImageState extends State<GoogleImage> {
  @override
  Widget build(BuildContext context) {
    if (this.widget.photoRef == null){
      return Image.asset(
              "assets/img/placeholder.png",
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitHeight
            );
    }
    return Container(
      child: FutureBuilder(
        future: PlaceApiProvider().getPlaceImageFromReference(widget.photoRef),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            print("Something went wrong");
            return Image.asset(
              "assets/img/placeholder.png",
              height: 200,
              width: MediaQuery.of(context).size.width,
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            //Show circular progress indicator if loading
            return Stack(children: [
              SizedBox(
                height: 200,
              ),
              Align(
                  alignment: Alignment.topCenter,
                  child: CircularProgressIndicator()),
            ]);
          }

          if (widget.cover == true) {
            print("To cover all the width");
            return Image(
                image: snapshot.data,
                height: 200,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fill);
          }
          return Image(image: snapshot.data);
        },
      ),
    );
  }
}

String searchImportantGoogleType(List<dynamic> types) {
  List<String> typePriority = ["lodging", "university", "school", 
  "subway_station", "bank", "health", "shopping_mall", "health", "store"];
  for (final x in typePriority){
    if (types.contains(x)) {
      if (x == "lodging") return "accommodation";
      return x;
    }
  }
  return types.first;
}
