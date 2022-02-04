import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/DataSource/tih_data_provider.dart';
import 'package:wikitude_flutter_app/UI/activity_icon_provider.dart';

class TIHEventDetails {
  String? uuid;
  String? name;
  String? description;
  String? body;
  String? price;
  double? latitude;
  double? longitude;
  String? organiser;
  String? imageUUID;
  String? imageURL;
  String? type;
  DateTime? startDate;
  DateTime? endDate;
  String? contactNumber;
  String? website;
  String? email;
  List<String>? language;
  String? nearstMRTStation;
  Icon? icon;
  Map<String,dynamic>? rawdata;


  TIHEventDetails.fromEventJSON(Map<String, dynamic> jsondata) {
    uuid = jsondata["uuid"];
    name = jsondata["name"];
    description = jsondata["description"];
    body = jsondata["body"];
    price = jsondata["price"];
    latitude = jsondata["location"]["latitude"] == null? 0: jsondata["location"]["latitude"].toDouble();
    longitude = jsondata["location"]["longitude"]== null? 0: jsondata["location"]["longitude"].toDouble();
    organiser = jsondata["eventOrganizer"]?? jsondata["companyDisplayName"];
    imageURL = jsondata["images"][0]["url"];
    imageUUID = jsondata["images"][0]["uuid"];
    type = jsondata["type"];
    startDate = DateTime.parse(jsondata["startDate"]);
    endDate = DateTime.parse(jsondata["endDate"]);
    contactNumber = jsondata["contact"]["primaryContactNo"];
    email = jsondata["officialEmail"];
    website = jsondata["officialWebsite"];
    language = List.castFrom(["supportedLanguage"]);
    nearstMRTStation = jsondata["nearestMrtStation"];
    icon = IconProvider().mapTIHEventIcon(type);
    rawdata = jsondata;
  }

  Map<String, dynamic> toJSON(){
    Map<String, dynamic> map = Map<String, dynamic>();
    map["uuid"] = uuid;
    map["name"] = name;
    map["description"] = description;
    map["body"] = body;
    map["price"] = price;
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    map["organiser"] = organiser;
    map["imageURL"] = imageURL;
    map["type"] = type;
    map["startDate"] = startDate;
    map["contactNumber"] = contactNumber;
    map["email"] = email;
    map["website"] = website;
    map["language"] = language;
    map["nearstMRTStation"] = nearstMRTStation;
    map["icon"] = icon;
    map["rawdata"] = rawdata;

    return map;

  }

  ImageProvider<Object> getImage() {
    //try fetch from "url"
    if (this.imageURL != null && this.imageURL != "") {
      print(imageURL);
      return NetworkImage(this.imageURL!);
    
    } else if (this.imageUUID != null && this.imageUUID != ""){
      //try fetch from uuid
      var downloadURL = TIHDataProvider.getImageURLByImageUUID(this.imageUUID!);
      print(downloadURL);
      return NetworkImage(downloadURL);
    } else {
      //no available image, return place holder
      print("WARNING: no image found for event");
      return AssetImage("assets/img/placeholder.png");
    }
  }
}