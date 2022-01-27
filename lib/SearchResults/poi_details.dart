import 'package:flutter/material.dart';

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

  var place;

  @override
  void initState() {
    super.initState();
  }

  fetchPOIDetails() async {
    print("place_id: " + widget.placeId);
    this.place = await PlaceApiProvider().getPlaceDetailFromId(widget.placeId);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.placeName),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
        future: fetchPOIDetails(),
        builder: (context, snapshot)  {
          if (snapshot.hasError) {
            print("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            //Show circular progress indicator if loading
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Container(
            child: Text(place.toString()),
          );
      }
    ));
  }
}