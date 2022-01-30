import 'package:wikitude_flutter_app/Plan/plan_model.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/User/user_database.dart';
import 'package:wikitude_flutter_app/User/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  final _cloudstore = UserDatabase();

  factory UserService() => _instance;

  UserService._internal() {
    _currentUser = null;
  }

  UserDetails? _currentUser;
  List<SearchResult> favoriteItems = <SearchResult>[];
  Plan? plan;

  //short getter for my variable
  UserDetails? get getCurrentUser => _currentUser;

  //short setter for my variable
  set setCurrentUser(UserDetails? user) => _currentUser = user;

  setDefaultEmailUser(String? uid) async {
    if (uid == null) {
      print("WARING: no uid input from email user creation!");
    } else {
      UserDetails? existedEmailUser = await _cloudstore.getUser(uid);
      if (existedEmailUser == null) {
        UserDetails user = UserDetails.newDefaultUser(uid);
        _cloudstore.addDefaultUser(user);
        print("SUCCESS: email user created and added to database: $uid");
      } else {
        _currentUser = existedEmailUser;
        favoriteItems = await getFavoriteItems().whenComplete(() {
        print("Favorite item fetched from database.");
      });
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
      print(
          "SUCCESS: Google user existed in database, hence retrieve the info from database: $uid");
      _currentUser = existedGoogleUser;
      favoriteItems = await getFavoriteItems().whenComplete(() {
        print("Favorite item fetched from database.");
      });
    }
  }

  logout() {
    _currentUser = null;
    favoriteItems = <SearchResult>[];
    plan = null;
  }

  List<String> getSearchHistory() {
    var history = <String>[];
    if (_currentUser != null && _currentUser?.searchHistory != null) {
      history = _currentUser!.searchHistory!;
      print("SUCCESS: search history is fetched from user.");
    } else {
      print("WARNING: no search history found for current user.");
    }
    return history;
  }

  void syncSearchHistory(List<String> searchHistory) {
    if (_currentUser != null) {
      _currentUser?.searchHistory = searchHistory;
      _cloudstore.updateUserProperty(_currentUser!);
      print("SUCCESS: user search history updated to database!");
    } else {
      print("WARNNING: not logged in. cannot sync search history.");
    }
  }

  void addToFavorite(SearchResult item) {
    favoriteItems.add(item);
    if (_currentUser == null) {
      print("WARNNING: cannot add to favorite, not logged in");
    } else {
      _cloudstore.addFavoriteItem(_currentUser!.uid!, item);
    }
  }

  void deleteFromFavorite(SearchResult item) {
    favoriteItems.remove(item);
    if (_currentUser == null) {
      print("WARNNING: cannot delete from favorite, not logged in");
    } else {
      _cloudstore.deleteFavoriteItem(_currentUser!.uid!, item);
    }
  }

  Future<List<SearchResult>> getFavoriteItems() async {
    //fetch from database
    var _favoriteJSONList =
        await _cloudstore.getFavoriteItemList(_currentUser!.uid!);
    this.favoriteItems = List.generate(_favoriteJSONList.length,
        (index) => SearchResult.fromDataBaseJSON(_favoriteJSONList[index]));
    return favoriteItems;
  }

  Future<bool> checkItemFavorited(SearchResult item) async {
    if (_currentUser == null) {
      print("WARNING: favorites not loaded due to not logged in");
      return false;
    }
    if (favoriteItems.isEmpty) {
      favoriteItems = await getFavoriteItems().whenComplete(() {
        print("SUCCESS: Favorite item fetched from database.");
      });
    }
    for (SearchResult faveItem in favoriteItems){
      if (faveItem.resultId == item.resultId) {
        print("Item is favorited");
        return true;
      }
    }
    return false;
  }
}
