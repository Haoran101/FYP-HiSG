import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
