class UserDetails {

  String? uid;
  String? displayName;
  String? email;
  String? photoURL;

  UserDetails.fromJSON(Map<String, dynamic> json){
    displayName = json["displayName"];
    email = json["email"];
    photoURL = json["photoURL"];
  }

  Map<String, dynamic> toJSON(){
    final Map<String, dynamic> mapData = new Map<String, dynamic>();

    mapData["displayName"] = this.displayName;
    mapData["email"] = this.email;
    mapData["photoURL"] = this.photoURL;

    return mapData;
  }

}