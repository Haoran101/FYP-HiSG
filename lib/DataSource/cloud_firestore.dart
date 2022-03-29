import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/UI/MRT_line_page.dart';
import 'cloud_firestore_look_up.dart' as lookuptables;

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class Image360Provider {
  final CollectionReference _image360Collection =
      firestore.collection('360_photos');

  Future<List<Map<String, dynamic>>?> listAllImage360() async {
    try {
      QuerySnapshot ytbSnapList = await _image360Collection.get();

      List<Map<String, dynamic>> ytbVideoList = [];
      for (var doc in ytbSnapList.docs) {
        if (doc.id != "Line") {
          ytbVideoList.add(doc.data() as Map<String, dynamic>);
        }
      }
      return ytbVideoList;
    } catch (error, stacktrace) {
      print(error);
      print(stacktrace);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> queryImage360ByTitle(text) async {
    try {
      final _lookup = lookuptables.photos360LookUp;
      Set<Map<String, dynamic>> resultList = {};
      for (final fullText in _lookup.keys) {
        if (fullText.toLowerCase().contains(text.toLowerCase())) {
          var returnedResult =
              await _image360Collection.doc(_lookup[fullText]).get();
          var returnedJson = returnedResult.data() as Map<String, dynamic>;
          resultList.add(returnedJson);
          if (resultList.length >= 20) {
            break;
          }
        }
      }
      return resultList.toList();
    } catch (error) {
      print(error);
      print("Failed to fetch 360 images from database");
      return null;
    }
  }
}

class Video360Provider {
  final CollectionReference _video360YoutubeCollection =
      firestore.collection('360_videos');
  final CollectionReference _video360StorageCollection =
      firestore.collection('360_video_storage');

  Future<List<Map<String, dynamic>>?> listAllVideo360YouTube() async {
    try {
      QuerySnapshot ytbSnapList = await _video360YoutubeCollection.get();

      List<Map<String, dynamic>> ytbVideoList = [];
      for (var doc in ytbSnapList.docs) {
        if (doc.id != "Line") {
          ytbVideoList.add(doc.data() as Map<String, dynamic>);
        }
      }
      return ytbVideoList;
    } catch (error, stacktrace) {
      print(error);
      print(stacktrace);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> listAllVideo360Storage() async {
    try {
      QuerySnapshot ytbSnapList = await _video360StorageCollection.get();

      List<Map<String, dynamic>> ytbVideoList = [];
      for (var doc in ytbSnapList.docs) {
        if (doc.id != "Line") {
          ytbVideoList.add(doc.data() as Map<String, dynamic>);
        }
      }
      return ytbVideoList;
    } catch (error, stacktrace) {
      print(error);
      print(stacktrace);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> queryYoutubeVideo360ByTitle(text) async {
    try {
      final _lookup = lookuptables.video360YouTubeLookUp;
      Set<Map<String, dynamic>> resultList = {};
      for (final fullText in _lookup.keys) {
        if (fullText.toLowerCase().contains(text.toLowerCase())) {
          var returnedResult =
              await _video360YoutubeCollection.doc(_lookup[fullText]).get();
          var returnedJson = returnedResult.data() as Map<String, dynamic>;
          resultList.add(returnedJson);
          if (resultList.length >= 20) break;
        }
      }
      return resultList.toList();
    } catch (error) {
      print(error);
      print("Failed to fetch 360 Youtube videos from database");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> queryStorageVideo360ByTitle(text) async {
    try {
      final _lookup = lookuptables.video360StorageLookUp;
      Set<Map<String, dynamic>> resultList = {};
      for (final fullText in _lookup.keys) {
        if (fullText.toLowerCase().contains(text.toLowerCase())) {
          var returnedResult =
              await _video360StorageCollection.doc(_lookup[fullText]).get();
          var returnedJson = returnedResult.data() as Map<String, dynamic>;
          resultList.add(returnedJson);
          if (resultList.length >= 20) break;
        }
      }
      return resultList.toList();
    } catch (error) {
      print(error);
      print("Failed to fetch 360 Storage videos from database");
      return null;
    }
  }
}

class MRTProvider {
  final CollectionReference _mrtCollection = firestore.collection('MRT');
  final Map<String, String> lineAbbvToLineName = {
    "EWL": "East West Line",
    "NSL": "North South Line",
    "NEL": "North East Line",
    "CCL": "Circle Line",
    "DTL": "Downtown Line",
    "TEL": "Thomson-East Coast Line",
    "BP": "Bukit Panjang LRT",
    "PG": "Punggol LRT line",
    "SK": "Sengkang LRT line"
  };

  final Map<String, String> codePrefixToLineAbbv = {
    "NS": "NSL",
    "EW": "EWL",
    "CG": "EWL",
    "NE": "NEL",
    "CC": "CCL",
    "CE": "CCL",
    "DT": "DTL",
    "BP": "BP",
    "STC": "SK",
    "SE": "SK",
    "SW": "SK",
    "PTC": "PG",
    "PE": "PG",
    "PW": "PG",
    "TE": "TEL",
  };

  final Map<String, String> lineAbbvToColorString = {
    "NSL": "red",
    "EWL": "green",
    "NEL": "purple",
    "CCL": "yellow",
    "DTL": "blue",
    "BP": "grey",
    "SK": "grey",
    "PG": "grey",
    "TEL": "brown",
  };

  String getLineNameFromAbbv(String lineAbbv) {
    return lineAbbvToLineName[lineAbbv]!;
  }

  String getLineAbbvFromLineCode(String code) {
    return codePrefixToLineAbbv[code]!;
  }

  String getLineNameFromLineCode(String code) {
    String lineAbbv = getLineAbbvFromLineCode(code);
    return lineAbbvToLineName[lineAbbv]!;
  }

  Color getColorFromLineAbbv(String lineAbbv) {
    String colorString = lineAbbvToColorString[lineAbbv]!;
    return MRTGraphicsGenerator.mrtColorMap(colorString);
  }

  Future<Map<String, dynamic>?> fetchMRTDetailsByPlaceId(placeId) async {
    QuerySnapshot mrtSnapList =
        await _mrtCollection.where("place_id", isEqualTo: placeId).get();
    QueryDocumentSnapshot mrtSnap = mrtSnapList.docs[0];
    return mrtSnap.data() as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> fetchMRTDetailsByDocRef(docref) async {
    DocumentReference<Object?> mrtSnap = _mrtCollection.doc(docref);
    DocumentSnapshot snapshot = await mrtSnap.get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      print(data["place_id"]);
      return data;
    } else {
      print("No MRT station found in database : $docref.");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> listAllMRTStation() async {
    try {
      QuerySnapshot mrtSnapList = await _mrtCollection.get();

      List<Map<String, dynamic>> mrtStationList = [];
      for (var doc in mrtSnapList.docs) {
        if (doc.id != "Line") {
          mrtStationList.add(doc.data() as Map<String, dynamic>);
        }
      }
      return mrtStationList;
    } catch (error, stacktrace) {
      print(error);
      print(stacktrace);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> queryMRT(text) async {
    try {
      final _lookup = lookuptables.mrtLookUp;
      Set<Map<String, dynamic>> resultList = {};
      for (final fullText in _lookup.keys) {
        if (fullText.toLowerCase().contains(text.toLowerCase())) {
          var returnedResult =
              await _mrtCollection.doc(_lookup[fullText]).get();
          var returnedJson = returnedResult.data() as Map<String, dynamic>;
          resultList.add(returnedJson);
          if (resultList.length >= 20) break;
        }
      }
      return resultList.toList();
    } catch (error) {
      print(error);
      print("Failed to fetch MRT from database");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> queryMRTLine(String lineCode) async {
    var returnedResult = await _mrtCollection.doc("Line").get();
    var allLines = returnedResult.data() as Map<String, dynamic>;
    List<Map<String, dynamic>> lineList = List.castFrom(allLines[lineCode]);
    print(lineList);
    return lineList;
  }
}

class HotelProvider {
  final CollectionReference _hotelCollection = firestore.collection('hotels');

  Future<Map<String, dynamic>?> queryHotelURLByPlaceId(id) async {
    DocumentReference docref = _hotelCollection.doc(id);
    DocumentSnapshot snapshot = await docref.get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      print(data["url"]);
      return data;
    } else {
      print("No hotel info found in database.");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> queryHotelByName(text) async {
    try {
      final _lookup = lookuptables.hotelsLookUp;
      Set<Map<String, dynamic>> resultList = {};
      for (final fullText in _lookup.keys) {
        if (fullText.toLowerCase().contains(text.toLowerCase())) {
          var returnedResult =
              await _hotelCollection.doc(_lookup[fullText]).get();
          var returnedJson = returnedResult.data() as Map<String, dynamic>;
          resultList.add(returnedJson);
          if (resultList.length >= 20) break;
        }
      }
      return resultList.toList();
    } catch (error) {
      print(error);
      print("Failed to fetch hotels from database");
      return null;
    }
  }
}

class TIHBackupProvider {
  final CollectionReference _backupCollection =
      firestore.collection('backupRecommendation');

  Future<List<Map<String, dynamic>>> _fetchBackUpListByInterest(
      interest) async {
    QuerySnapshot interestSnapList =
        await _backupCollection.where("interest", isEqualTo: interest).get();

    List<QueryDocumentSnapshot> interestSnap = interestSnapList.docs;

    List<Map<String, dynamic>> items = [];
    for (final QueryDocumentSnapshot item in interestSnap) {
      Map<String, dynamic> interestItem = item.data() as Map<String, dynamic>;
      items.add(interestItem);
    }
    return items;
  }

  Future<List<Map<String, dynamic>>> getBackupSearchResultList(
      List<String> interests) async {
    Map<String, int> disMap = _distributionMap(interests);
    List<Map<String, dynamic>> finalItems = [];
    for (final interest in interests) {
      List<Map<String, dynamic>> interestItems =
          await _fetchBackUpListByInterest(interest);
      List<Map<String, dynamic>> interestSr =
          _randomSelector(interestItems, disMap[interest]!);
      finalItems.addAll(interestSr);
    }
    return finalItems;
  }

  Map<String, int> _distributionMap(List<String> interests) {
    Map<String, int> map = {};
    Random rand = new Random();
    int total = rand.nextInt(2) + 6;
    int each = (total / interests.length).floor();
    int last = total - each * (interests.length - 1);
    int lastIndex = rand.nextInt(interests.length);

    int i = 0;
    while (i < interests.length) {
      String interest = interests[i];
      map[interest] = (i == lastIndex) ? last : each;
      i++;
    }

    return map;
  }

  List<Map<String, dynamic>> _randomSelector(
      List<Map<String, dynamic>> interestItemList, int number) {
    Set<Map<String, dynamic>> selectedItems = Set();
    while (selectedItems.length < number) {
      Random rand = new Random();
      Map<String, dynamic> item =
          interestItemList[rand.nextInt(interestItemList.length)];
      selectedItems.add(item);
    }
    return List.from(selectedItems);
  }
}
