import 'package:flutter/material.dart';
import 'package:hi_sg/Plan/plan_model.dart';
import 'package:hi_sg/Models/search_result_model.dart';
import 'package:hi_sg/User/user_database.dart';
import 'package:hi_sg/User/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  final _cloudstore = UserDatabase();

  factory UserService({Key? key}) => _instance;

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
        await getPlan().then((p) {
          this.plan = p;
          print("Plan item fetched from database.");
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
      await getPlan().then((p) {
        this.plan = p;
        print("Plan item fetched from database.");
      });
    }
  }

  logout() {
    this._currentUser = null;
    this.favoriteItems = <SearchResult>[];
    this.plan = null;
  }

  List<String> getSearchHistory() {
    var history = <String>[];
    if (_currentUser != null && _currentUser?.searchHistory != null) {
      history = _currentUser!.searchHistory!;
      //print("SUCCESS: search history is fetched from user.");
    } else {
      //print("WARNING: no search history found for current user.");
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
    for (SearchResult faveItem in favoriteItems) {
      if (faveItem.resultId == item.resultId) {
        print("Item is favorited");
        return true;
      }
    }
    return false;
  }

  Future<Plan?> getPlan() async {
    if (_currentUser == null) {
      print("WARNING: unable to get plan due to not logged in");
      return null;
    }

    if (this.plan != null) {
      print("Plan fetched from cache");
      return this.plan;
    } else {
      Map<String, dynamic> planKeyJSON =
          await _cloudstore.getPlannedItemMain(_currentUser!.uid!);
      print(planKeyJSON);
      Plan _p = Plan(main: planKeyJSON);
      _p.init().whenComplete(() {
        this.plan = _p;
        print("Plan fetched from database");
        return _p;
      });
    }
  }

  Future<List<SearchResult>> fetchSearchResultsFromId(
      List<String> itemRefs) async {
    List<SearchResult> dayItemList = [];
    for (final itemRef in itemRefs) {
      _cloudstore
          .getPlannedDayItem(_currentUser!.uid!, itemRef)
          .then((itemJSON) {
        SearchResult sr = SearchResult.fromDataBaseJSON(itemJSON);
        print(sr.resultId);
        dayItemList.add(sr);
      });
    }
    return dayItemList;
  }

  void addToPlanArchieve(SearchResult item) async {
    print(plan!.toString());
    if (_currentUser == null) {
      print("WARNING: unable to get plan due to not logged in");
      return;
    }
    if (plan == null) {
      await getPlan().then((p) {
        this.plan = p;
        print("SUCCESS: unable to get plan due to not logged in");
        try {
          plan!.addToArchieve(item);
          print(plan.toString());
          _cloudstore.addPlanItem(_currentUser!.uid!, item);
          print("SUCCESS: item added to plan > archieve");
        } catch (error, stacktrace) {
          print(error);
          print(stacktrace);
        }
      });
    } else {
      try {
        plan!.addToArchieve(item);
        _cloudstore.addPlanItem(_currentUser!.uid!, item);
        print("SUCCESS: item added to plan > archieve");
      } catch (error, stacktrace) {
        print(error);
        print(stacktrace);
      }
    }
  }

  void addRecommendedPlanItem(SearchResult item) {
    try {
        _cloudstore.addRecommendedPlanItem(_currentUser!.uid!, item);
        print("SUCCESS: item added to plan collection: ${item.resultId}");
      } catch (error, stacktrace) {
        print(error);
        print(stacktrace);
      }
  }

  Future<bool> checkItemInPlan(SearchResult item) async {
    if (_currentUser == null) {
      print("WARNING: unable to get plan due to not logged in");
      return false;
    }
    await getPlan().then((p) {
      this.plan = p;
      print("plan: " + plan!.toString());
    });

    for (Day d in plan!.dayList) {
      for (var planedRef in d.getActivityIdList()) {
        if (planedRef == item.resultId) return true;
      }
    }
    return false;
  }

  updatePlanMainInDatabase(Plan inputPlan){
    this.plan = inputPlan;
    var planMain = inputPlan.toMainJSON();
    _cloudstore.updatePlannMainJSON(_currentUser!.uid!, planMain).whenComplete(
      () => print("SUCCESS: updated plan main in collection.")
    );
  }
}
