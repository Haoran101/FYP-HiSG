import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wikitude_flutter_app/Models/user_model.dart';
import 'cloud_firestore_look_up.dart' as lookuptables;

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class UserDatabase {
  final CollectionReference _userCollection = firestore.collection('users');

  //add a new default user (email)
  Future<UserDetails?> addDefaultUser(String? uid) async {
    UserDetails user = UserDetails.newDefaultUser(uid!);
    DocumentReference documentReferencer = _userCollection.doc(user.uid);

    var data = user.toJSON();

    await documentReferencer.set(data).whenComplete(() {
      print("New user $uid added to the database");
      return user;
    }).catchError((e) => print(e));

    return null;
  }

  //add a new default google user
  Future<UserDetails?> addDefaultGoogleUser(
      String? uid, String? displayName, String? photoURL) async {
    UserDetails user =
        UserDetails.newDefaultGoogleUser(uid!, displayName!, photoURL!);
    DocumentReference documentReferencer = _userCollection.doc(user.uid);

    var data = user.toJSON();

    await documentReferencer.set(data).whenComplete(() {
      print("New user $uid added to the database");
      return user;
    }).catchError((e) => print(e));

    return null;
  }

  //get user document from firestore
  Future<UserDetails?> getUser(String? uid) async {
    try {
      var userFromDataBaseSnapshot = await _userCollection.doc(uid).get();
      Map<String, dynamic> userdata =
          userFromDataBaseSnapshot.data() as Map<String, dynamic>;
      return UserDetails.fromMap(userdata);
    } catch (error) {
      print(error);
      return null;
    }
  }

  //update properties of user
  updateUserProperty(UserDetails userInfo) async {
    Map<String, dynamic> updateItems = userInfo.toJSON();
    DocumentReference docRef = _userCollection.doc(userInfo.uid);
    await docRef.set(updateItems);
  }
}

class Image360Provider {
  final CollectionReference _image360Collection =
      firestore.collection('360_photos');

  Future<List<Map<String, dynamic>>?> queryImage360ByTitle(text) async {
    try {
      final _lookup = lookuptables.photos360LookUp;
      Set<Map<String, dynamic>> resultList = {};
      for (final fullText in _lookup.keys){
        if (fullText.toLowerCase().contains(text.toLowerCase())){
          var returnedResult = await _image360Collection.doc(_lookup[fullText]).get();
          var returnedJson = returnedResult.data() as Map<String, dynamic>;
          resultList.add(returnedJson);
          if (resultList.length >= 20) {break;}
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
  //TODO: change query method
  final CollectionReference _video360YoutubeCollection =
      firestore.collection('360_videos');
  final CollectionReference _video360StorageCollection =
      firestore.collection('360_video_storage');

  Future<List<Map<String, dynamic>>?> queryYoutubeVideo360ByTitle(text) async {
    try {
      final _lookup = lookuptables.video360YouTubeLookUp;
      Set<Map<String, dynamic>> resultList = {};
      for (final fullText in _lookup.keys){
        if (fullText.toLowerCase().contains(text.toLowerCase())){
          var returnedResult = await _video360YoutubeCollection.doc(_lookup[fullText]).get();
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
      for (final fullText in _lookup.keys){
        if (fullText.toLowerCase().contains(text.toLowerCase())){
          var returnedResult = await _video360StorageCollection.doc(_lookup[fullText]).get();
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
  final CollectionReference _mrtCollection =
      firestore.collection('MRT');

  Future<List<Map<String, dynamic>>?> queryMRT(text) async {
    try {
      final _lookup = lookuptables.mrtLookUp;
      Set<Map<String, dynamic>> resultList = {};
      for (final fullText in _lookup.keys){
        if (fullText.toLowerCase().contains(text.toLowerCase())){
          var returnedResult = await _mrtCollection.doc(_lookup[fullText]).get();
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
}

class HotelProvider {
  final CollectionReference _hotelCollection =
      firestore.collection('hotels');

  Future<List<Map<String, dynamic>>?> queryHotelByName(text) async {
    try {
      final _lookup = lookuptables.hotelsLookUp;
      Set<Map<String, dynamic>> resultList = {};
      for (final fullText in _lookup.keys){
        if (fullText.toLowerCase().contains(text.toLowerCase())){
          var returnedResult = await _hotelCollection.doc(_lookup[fullText]).get();
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