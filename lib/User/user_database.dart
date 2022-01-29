
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/User/user_model.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class UserDatabase {
  final CollectionReference _userCollection = firestore.collection('users');
  final emptyPlanTemplate = {"days" : []};

  //add a new default user (email)
  void addDefaultUser(UserDetails user) async {
    DocumentReference documentReferencer = _userCollection.doc(user.uid);
    var data = user.toJSON();
    var uid = user.uid;
    await documentReferencer.set(data).whenComplete(() {
      print("New user $uid added to the database");
    }).catchError((e, stackTrace) {
      print(e);
      print(stackTrace);
    });

    //add empty plan placeholder
    DocumentReference planMain = documentReferencer.collection("plan").doc("main");
    await planMain.set(emptyPlanTemplate).whenComplete(() {
      print("New empty plan added to the database $uid ");
    }).catchError((e, stackTrace) {
      print(e);
      print(stackTrace);
    });

  }

  //add a new default google user
  void addDefaultGoogleUser(UserDetails googleUser) async {
    DocumentReference documentReferencer = _userCollection.doc(googleUser.uid);

    var data = googleUser.toJSON();
    var uid = googleUser.uid;

    await documentReferencer.set(data).whenComplete(() {
      print("New user $uid added to the database");
    }).catchError((e) => print(e));

     //add empty plan placeholder
    DocumentReference planMain = documentReferencer.collection("plan").doc("main");
    await planMain.set(emptyPlanTemplate).whenComplete(() {
      print("New empty plan added to the database $uid ");
    }).catchError((e, stackTrace) {
      print(e);
      print(stackTrace);
    });
  }

  //get user document from firestore
  Future<UserDetails?> getUser(String? uid) async {
    try {
      var userFromDataBaseSnapshot = await _userCollection.doc(uid).get();
      Map<String, dynamic> userdata =
          userFromDataBaseSnapshot.data() as Map<String, dynamic>;
      return UserDetails.fromMap(userdata);
    } catch (error, stacktrace) {
      print(error);
      print(stacktrace);
      return null;
    }
  }

  //update properties of user
  updateUserProperty(UserDetails userInfo) async {
    Map<String, dynamic> updateItems = userInfo.toJSON();
    var uid = userInfo.uid;
    DocumentReference docRef = _userCollection.doc(userInfo.uid);
    await docRef.set(updateItems).whenComplete(() {
      print("SUCCESS: $uid items updated to the database");
    }).catchError((e, stackTrace) => [e, stackTrace].forEach(print));
  }

  //add item to favorite
  addFavoriteItem(String uid, SearchResult searchResult) async {
    var itemData = searchResult.toJSON();
    var resultId = itemData["resultId"];
    DocumentReference docRef = _userCollection.doc(uid).collection('favorite').doc(resultId);
    await docRef.set(itemData).whenComplete(() {
      print("SUCCESS: $resultId added to favorite");
    }).catchError((e, stackTrace) => [e, stackTrace].forEach(print));
  }

  //delete item in favorite
  deleteFavoriteItem(String uid, SearchResult searchResult) async {
    var itemData = searchResult.toJSON();
    var resultId = itemData["resultId"];
    DocumentReference docRef = _userCollection.doc(uid).collection('favorite').doc(resultId);
    await docRef.delete().whenComplete(() {
      print("SUCCESS: $resultId deleted in favorite");
    }).catchError((e, stackTrace) => [e, stackTrace].forEach(print));
  }

  Future<List<Map<String, dynamic>>> getFavoriteItemList(String uid) async {
    CollectionReference<Map<String, dynamic>> _favoriteCollection = _userCollection.doc(uid).collection("favorite");
    QuerySnapshot snapshot = await _favoriteCollection.get();
    return List.generate(snapshot.docs.length, (index) => 
      snapshot.docs[index].data() as Map<String, dynamic>
    );
  }
}
