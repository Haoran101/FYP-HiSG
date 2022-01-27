import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wikitude_flutter_app/Models/user_model.dart';

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
      QuerySnapshot<Object?> result = await _image360Collection
          .get();
      List<Map<String, dynamic>> Images = [];
      int returnCount = 0;
      for (final returnedResult in result.docs){
        var returnedJson = returnedResult.data() as Map<String, dynamic>;
        if (returnedJson['title'].toString().toLowerCase().contains(text.toLowerCase())){
            Images.add(returnedResult.data() as Map<String, dynamic>);
            returnCount++;
        }
        if (returnCount > 19){
          break;
        }
      }
      return Images;
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
      QuerySnapshot<Object?> result = await _video360YoutubeCollection
          .where('snippet.title', isGreaterThanOrEqualTo: text)
          .where('snippet.title', isLessThanOrEqualTo: text + "\uf8ff")
          .get();
      List<Map<String, dynamic>> Videos = [];
      result.docs.forEach((returnedResult) {
        Videos.add(returnedResult.data() as Map<String, dynamic>);
      });
      return Videos;
    } catch (error) {
      print(error);
      print("Failed to fetch 360 Youtube videos from database");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> queryStorageVideo360ByTitle(text) async {
    try {
      Set<Map<String, dynamic>> Videos = Set();
      QuerySnapshot<Object?> result = await _video360StorageCollection
          .where('name', isGreaterThanOrEqualTo: text)
          .where('name', isLessThanOrEqualTo: text + "~")
          .get();
      
      result.docs.forEach((returnedResult) {
        Videos.add(returnedResult.data() as Map<String, dynamic>);
      });

      QuerySnapshot<Object?> result2 = await _video360StorageCollection
          .where('description', isGreaterThanOrEqualTo: text)
          .where('description', isLessThanOrEqualTo: text + "~")
          .get();
      
      result2.docs.forEach((returnedResult) {
        Videos.add(returnedResult.data() as Map<String, dynamic>);
      });

      return Videos.toList();
    } catch (error) {
      print(error);
      print("Failed to fetch 360 Storage videos from database");
      return null;
    }
  }
}

class MRTProvider {
  //TODO: change query method
  final CollectionReference _mrtCollection =
      firestore.collection('MRT');

  Future<List<Map<String, dynamic>>?> queryMRT(text) async {
    try {
      Set<Map<String, dynamic>> mrtStations = Set();
      //Name english, malay
      QuerySnapshot<Object?> result = await _mrtCollection
          .where('Name Engish Malay', isGreaterThanOrEqualTo: text)
          .where('Name Engish Malay', isLessThanOrEqualTo: text + "~")
          .get();
      
      result.docs.forEach((returnedResult) {
        mrtStations.add(returnedResult.data() as Map<String, dynamic>);
      });

      //name chinese
      QuerySnapshot<Object?> result2 = await _mrtCollection
          .where('Name Chinese', isGreaterThanOrEqualTo: text)
          .where('Name Chinese', isLessThanOrEqualTo: text + "~")
          .get();
      
      result2.docs.forEach((returnedResult) {
        mrtStations.add(returnedResult.data() as Map<String, dynamic>);
      });

      //name Name Tamil
      QuerySnapshot<Object?> result3 = await _mrtCollection
          .where('Name Tamil', isGreaterThanOrEqualTo: text)
          .where('Name Tamil', isLessThanOrEqualTo: text + "~")
          .get();
      
      result3.docs.forEach((returnedResult) {
        mrtStations.add(returnedResult.data() as Map<String, dynamic>);
      });

      //name codes, e.g. EW3
      QuerySnapshot<Object?> result4 = await _mrtCollection
          .where('name codes', arrayContains: text.toUpperCase())
          .get();
      
      result4.docs.forEach((returnedResult) {
        mrtStations.add(returnedResult.data() as Map<String, dynamic>);
      });

      return mrtStations.toList();
    } catch (error) {
      print(error);
      print("Failed to fetch MRT from database");
      return null;
    }
  }
}

class HotelProvider {
  //TODO: change query method
  final CollectionReference _hotelCollection =
      firestore.collection('hotels');

  Future<List<Map<String, dynamic>>?> queryHotelByName(text) async {
    try {
      QuerySnapshot<Object?> result = await _hotelCollection
          .where('name', isGreaterThanOrEqualTo: text)
          .where('name', isLessThanOrEqualTo: text + "\uf8ff")
          .get();
      List<Map<String, dynamic>> hotels = [];
      result.docs.forEach((returnedResult) {
        hotels.add(returnedResult as Map<String, dynamic>);
      });
      return hotels;
    } catch (error) {
      print(error);
      print("Failed to fetch hotels from database");
      return null;
    }
  }
}