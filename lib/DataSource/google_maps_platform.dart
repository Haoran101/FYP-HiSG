// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../Models/poi_model.dart';
import 'api_key.dart' as maps_api;

class TestPOI extends StatefulWidget {
  const TestPOI({Key? key}) : super(key: key);

  @override
  State<TestPOI> createState() => _TestPOIState();
}

class _TestPOIState extends State<TestPOI> {

  getPOI() async{
    var test = await PlaceApiProvider().getPlaceDetailFromId("ChIJrTLr-GyuEmsRBfy61i59si0");
    var image = await PlaceApiProvider().getPlaceImageFromReference(test!.photoReferences![0]);
    print(image);
    return image;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: FutureBuilder(
        future: getPOI(), 
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

          if (snapshot.hasError) {
            print("Something went wrong");
            return (Image.asset("assets/img/placeholder.png"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            //Show circular progress indicator if loading
            return Align(
              alignment: Alignment.topCenter,
              child: CircularProgressIndicator());
          }
          return Image(image: snapshot.data);
        },
        
      ),
    );
  }
}

class PlaceApiProvider {
  final httpClient = Client();
  final API_KEY = maps_api.google_maps_api_key;

  Future<List<Map<String, dynamic>>?> getGooglePlaceListByTextSearch(text) async{
    final Uri request = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$text&location=1.290270,103.851959&radius=30000&key=$API_KEY"
    );
    print(request.toString());
    final response = await httpClient.get(request);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final list = result['results'];
        print(list);
        final jsonPlaceList = List.generate(
          list.length,
          (index) => list[index] as  Map<String, dynamic>
        );
        return jsonPlaceList;
      } else {
        print("Error fetching place from google places text search API!");
        return null;
      }
    }
  }

  Future<POI?> getPlaceDetailFromId(String placeId) async {
    final Uri request = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$API_KEY');
    print(request.toString());
    final response = await httpClient.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final json = result['result'] as Map<String, dynamic>;
        // build result
        final poi = POI.fromJSON(json);
        return poi;
      } else {
        print("Error fetching place from google places details API!");
        return null;
      }
    }
  }

  Future<NetworkImage> getPlaceImageFromReference(String photoReference) async {
    final String imageRequest = 
        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&photo_reference=$photoReference&key=$API_KEY';
    
    return NetworkImage(imageRequest);
  }

}