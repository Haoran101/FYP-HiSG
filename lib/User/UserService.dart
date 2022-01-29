import 'package:wikitude_flutter_app/Models/plan_model.dart';
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
  List<SearchResult> _favoriteItems = <SearchResult>[];
  bool _fetchedFavoriteFromDatabase = false;
  Plan? plan;

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

  void addToFavorite(SearchResult item) {
    _favoriteItems.add(item);
    if (_currentUser == null){
      print("WARNNING: cannot add to favorite, not logged in");
    } else {
      _cloudstore.addFavoriteItem(_currentUser!.uid!, item);
    }
  }

  void deleteFromFavorite(SearchResult item) {
    _favoriteItems.remove(item);
    if (_currentUser == null){
      print("WARNNING: cannot delete from favorite, not logged in");
    } else {
      _cloudstore.deleteFavoriteItem(_currentUser!.uid!, item);
    }
  }

  Future<List<SearchResult>> getFavoriteItems() async{
    if (!_fetchedFavoriteFromDatabase){
      //fetch from database
      var _favoriteJSONList = await _cloudstore.getFavoriteItemList(_currentUser!.uid!);
      _favoriteItems = List.generate(_favoriteJSONList.length, (index) => 
      SearchResult.fromDataBaseJSON(_favoriteJSONList[index]));
      _fetchedFavoriteFromDatabase = true;
    }
    return _favoriteItems;
  }

  bool checkItemFavorited(SearchResult item) {
    if (!_fetchedFavoriteFromDatabase){
      getFavoriteItems();
      return _favoriteItems.contains(item);
    }
    return _favoriteItems.contains(item);
  }
}
