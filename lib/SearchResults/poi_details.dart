import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../DataSource/google_maps_platform.dart';
import '../Models/poi_model.dart';

class POISubPage extends StatefulWidget {
  final placeName;
  final placeId;
  const POISubPage({required this.placeName, required this.placeId});

  @override
  _POISubPageState createState() => _POISubPageState();
}

class _POISubPageState extends State<POISubPage> {
  late POI place;
  List imageList = [];

  @override
  void initState() {
    fetchPOIDetails();
    super.initState();
  }

  fetchPOIDetails() async{
    print("place_id: " + widget.placeId);
    this.place =
        (await PlaceApiProvider().getPlaceDetailFromId(widget.placeId))!;
  }

  @override
  Widget build(BuildContext context) {
    var _pageElementPadding = EdgeInsets.all(20.0);

    getPhotoView() {
      if (this.place.photoReferences!.length < 3){
        return GoogleImage(
          photoRef: place.photoReferences![0],
          cover: true);
      } else {
      return 
      Container(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
              children: List.generate(
                  place.photoReferences!.length,
                  (index) => GoogleImage(
                      photoRef: place.photoReferences![index],
                      cover: false))),
        );
      }
    }

    return Container(
      child: FutureBuilder(
              future: fetchPOIDetails(),
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
                print("Number of photos: " + place.photoReferences!.length.toString());
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      //Image scrollable horizontal
                      getPhotoView()
                      ,
                      //Title
                      Padding(
                        padding: _pageElementPadding,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text( place.name!,
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                      ),

                      //rating bar and direction arrow
                      Padding(
                        padding: _pageElementPadding,
                        child: Row(
                          children: [
                            //rating bar
                            place.rating == null
                                ? SizedBox(
                                    width: 0,
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(place.rating.toString(),
                              style: TextStyle(fontSize: 20),),
                            ),
                            Spacer(),
                            //direction button
                            InkWell(
                              child: Icon(
                                Icons.near_me_outlined,
                                size: 40,
                                color: Colors.red[400]
                              ),
                              onTap: () => print("Tapped direction arrow"),
                              //TODO: navigate to directions page
                            )
                          ],
                        ),
                      ),

                      //TODO: details info: address, opening hours, phone number, website
                      //TODO: 360 experiences
                      //TODO: reviews
                      //TODO: related articles
                      //TODO: Nearby places/events/something
                    ],
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
    return Container(
      child: FutureBuilder(
        future: PlaceApiProvider().getPlaceImageFromReference(widget.photoRef),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            print("Something went wrong");
            return Image.asset("assets/img/placeholder.png",
                  height: 200,
                  width: MediaQuery.of(context).size.width,);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            //Show circular progress indicator if loading
            return Stack(children: [
              SizedBox(height: 200,),
              Align(
                  alignment: Alignment.topCenter,
                  child: CircularProgressIndicator()),
            ]);
          }

          if (widget.cover == true){
            print("To cover all the width");
            return Image(image: snapshot.data,
              height: 200,
              width: MediaQuery.of(context).size.width,
              fit:BoxFit.fill
            );
          }
          return Image(image: snapshot.data);
        },
      ),
    );
  }
}
