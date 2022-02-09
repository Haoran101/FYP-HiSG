import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloud_firestore_look_up.dart' as lookuptables;

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class Image360Provider {
  final CollectionReference _image360Collection =
      firestore.collection('360_photos');

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

  Future<List<Map<String, dynamic>>?> queryMRTLine(String lineCode) async{
    var returnedResult =
              await _mrtCollection.doc("Line").get();
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
