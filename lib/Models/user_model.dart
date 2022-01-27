
final defaultProfilePhotoURL = "https://thumbs.dreamstime.com/b/default-avatar-profile-vector-user-profile-default-avatar-profile-vector-user-profile-profile-179376714.jpg";

class UserDetails {

  String? uid;
  String? displayName;
  String? photoURL;
  List<Map<String, dynamic>>? collectedBadges;
  List<String>? searchHistory;
  List<Map<String, dynamic>>? savedItems;
  Map<String, dynamic>? settings;

  toString() {
    return "User(uid: $uid, displayName: $displayName, photoURL: $photoURL)";
  }


  UserDetails.fromMap(Map<String, dynamic> mapData) {
    uid = mapData["uid"] as String;
    displayName = mapData["displayName"] as String;
    photoURL = mapData["photoURL"] as String;
    collectedBadges = List<Map<String, dynamic>>.from(mapData["collectedBadges"]);
    searchHistory = List<String>.from(mapData["searchHistory"]);
    savedItems = List<Map<String, dynamic>>.from(mapData["savedItems"]);
    settings = mapData["settings"] as Map<String, dynamic>;
  }

  UserDetails.newDefaultUser(String uidInput){
    uid = uidInput;
    displayName = "USER " + uidInput.substring(0,8);
    photoURL = defaultProfilePhotoURL;
    collectedBadges = <Map<String, dynamic>>[];
    searchHistory = <String>[];
    savedItems = <Map<String, dynamic>>[];
    settings = Map<String, dynamic>();
  }

  UserDetails.newDefaultGoogleUser(String uidInput, String displayNameInput, String photoURLInput){
    uid = uidInput;
    displayName = displayNameInput;
    photoURL = photoURLInput;
    collectedBadges = <Map<String, dynamic>>[];
    searchHistory = <String>[];
    savedItems = <Map<String, dynamic>>[];
    settings = Map<String, dynamic>();
  }

  Map<String, dynamic> toJSON(){
    final Map<String, dynamic> mapData = new Map<String, dynamic>();
    mapData["uid"] = this.uid;
    mapData["displayName"] = this.displayName;
    mapData["photoURL"] = this.photoURL;
    mapData["collectedBadges"] = this.collectedBadges;
    mapData["searchHistory"] = this.searchHistory;
    mapData["savedItems"] = this.savedItems;
    mapData["settings"] = this.settings;
    return mapData;
  }

}