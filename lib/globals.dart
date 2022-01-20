library my_prj.globals;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:wikitude_flutter_app/DataSource/cloud_firestore.dart';
import 'package:wikitude_flutter_app/Models/user_model.dart';

class Globals {

  static final Globals _instance = Globals.setUser();

  // passes the instantiation to the _instance object
  factory Globals() => _instance;

  UserDetails? currentUser;

  Globals.setUser(){
    UserDatabase().getUser(FirebaseAuth.instance.currentUser!.uid);
  }
}

bool isSignedIn = FirebaseAuth.instance.currentUser != null;
