import 'package:wikitude_flutter_app/DataSource/cloud_firestore.dart';
import 'package:wikitude_flutter_app/Models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  final _cloudstore = UserDatabase();

  factory UserService() => _instance;

  UserService._internal() {
    _currentUser = null;
  }

  UserDetails? _currentUser;

  //short getter for my variable
  UserDetails? get getCurrentUser => _currentUser;

  //short setter for my variable
  set setCurrentUser(UserDetails? user) => _currentUser = user;

  setDefaultEmailUser(String? uid) async{
    if (uid == null){
      print("WARING: no uid input from email user creation!");
    } else {
      UserDetails? existedEmailUser = await _cloudstore.getUser(uid);
      if (existedEmailUser == null){
        UserDetails user = UserDetails.newDefaultUser(uid);
      _currentUser = user;
      _cloudstore.addDefaultUser(user);
      print("SUCCESS: email user created and added to database: $uid");
      } else {
        _currentUser = existedEmailUser;
        print("SUCCESS: email user existed retrieved from database: $uid");
      }
      
    }
  }

  setDefaultGoogleUser(
      String? uid, String? displayName, String? photoURL) async {
    UserDetails? existedGoogleUser = await _cloudstore.getUser(uid);

    //No previous Google User
    if (existedGoogleUser == null) {
      print("Google User not existed in database, hence create a new user.");
      if (uid == null) {
        print("WARNING: no uid input is provided");
      } else {
        UserDetails newGoogleUser =
            UserDetails.newDefaultGoogleUser(uid, displayName, photoURL);
        _currentUser = newGoogleUser;
        _cloudstore.addDefaultGoogleUser(newGoogleUser);
        print("SUCCESS: Google user created and added to database: $uid");
      }
    } else {
      print("SUCCESS: Google user existed in database, hence retrieve the info from database: $uid");
      _currentUser = existedGoogleUser;
    }
  }

  List<String> getSearchHistory() {
    var history = <String>[];
    if (_currentUser != null && _currentUser?.searchHistory != null){
        history = _currentUser!.searchHistory!;
        print("SUCCESS: search history is fetched from user.");
    } else {
      print("WARNING: no search history found for current user.");
    }
    return history;
  }

  void syncSearchHistory(List<String> searchHistory) {
    if (_currentUser != null){
      _currentUser?.searchHistory = searchHistory;
      _cloudstore.updateUserProperty(_currentUser!);
      print("SUCCESS: user search history updated to database!");
    } else {
      print("WARNNING: not logged in. cannot sync search history.");
    }
  }

}
