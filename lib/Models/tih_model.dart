import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/DataSource/tih_data_provider.dart';
import 'package:wikitude_flutter_app/UI/activity_icon_provider.dart';
import 'package:basic_utils/basic_utils.dart';

class TIHDetails {
  String? uuid;
  String? name;
  String? description;
  String? body;
  String? price;
  double? latitude;
  double? longitude;
  List<String>? businessHour;
  String? organiser;
  String? notes;
  String? imageUUID;
  String? imageURL;
  String? type;
  DateTime? startDate;
  DateTime? endDate;
  String? tourStartPoint;
  String? tourEndPoint;
  String? contactNumber;
  bool? wheelChairFriendly;
  bool? childFriendly;
  String? minimumAge;
  String? duration;
  String? website;
  String? email;
  List<String>? supportLanguage;
  String? language;
  String? nearstMRTStation;
  Icon? icon;
  Map<String, dynamic>? rawdata;

  TIHDetails.fromEventJSON(Map<String, dynamic> jsondata) {
    uuid = jsondata["uuid"];
    name = jsondata["name"];
    description = jsondata["description"];
    body = jsondata["body"];
    price = jsondata["price"];

    latitude = jsondata["location"]["latitude"] == null
        ? 0
        : jsondata["location"]["latitude"].toDouble();
    longitude = jsondata["location"]["longitude"] == null
        ? 0
        : jsondata["location"]["longitude"].toDouble();
    organiser = jsondata["eventOrganizer"] ?? jsondata["companyDisplayName"];
    imageURL = jsondata["images"][0]["url"];
    imageUUID = jsondata["images"][0]["uuid"];
    type = jsondata["type"];
    startDate = DateTime.parse(jsondata["startDate"]);
    endDate = DateTime.parse(jsondata["endDate"]);
    contactNumber = jsondata["contact"]["primaryContactNo"];
    email = jsondata["officialEmail"];
    website = jsondata["officialWebsite"];
    supportLanguage = List.castFrom(["supportedLanguage"]);
    nearstMRTStation = jsondata["nearestMrtStation"];
    icon = IconProvider().mapTIHEventIcon(type);
    rawdata = jsondata;
  }

  TIHDetails.fromTourJSON(Map<String, dynamic> jsondata) {
    uuid = jsondata["uuid"];
    name = jsondata["name"];
    notes = jsondata["notes"];
    description = jsondata["description"];
    body = jsondata["body"];
    price = jsondata["price"];
    wheelChairFriendly = jsondata["wheelChairFriendly"] == "Y" ? true : false;
    childFriendly = jsondata["childFriendly"] == "Y" ? true : false;
    minimumAge = jsondata["minimumAge"];
    latitude = jsondata["location"]["latitude"] == null
        ? 0
        : jsondata["location"]["latitude"].toDouble();
    longitude = jsondata["location"]["longitude"] == null
        ? 0
        : jsondata["location"]["longitude"].toDouble();
    organiser = jsondata["companyDisplayName"];
    imageURL =
        jsondata["images"].length > 0 ? jsondata["images"][0]["url"] : null;
    imageUUID =
        jsondata["images"].length > 0 ? jsondata["images"][0]["uuid"] : null;
    type = jsondata["type"];
    tourStartPoint = jsondata["startingPoint"];
    tourEndPoint = jsondata["endingPoint"];
    duration = jsondata["tourDuration"];
    startDate = jsondata["startDate"] != null
        ? DateTime.parse(jsondata["startDate"])
        : null;
    endDate = jsondata["endDate"] != null
        ? DateTime.parse(jsondata["endDate"])
        : null;
    contactNumber = jsondata["contact"]["primaryContactNo"];
    email = jsondata["officialEmail"];
    website = jsondata["officialWebsite"];
    language = jsondata["language"];
    nearstMRTStation = jsondata["nearestMrtStation"];
    businessHour = _getBusinessHour(jsondata["businessHour"]);
    icon = IconProvider().mapTIHEventIcon(type);
    //TODO: map tour types and icons
    rawdata = jsondata;
  }

  TIHDetails.fromPrecinctsJSON(Map<String, dynamic> jsondata) {
    uuid = jsondata["uuid"];
    name = jsondata["name"];
    description = jsondata["description"];
    imageURL =
        jsondata["images"].length > 0 ? jsondata["images"][0]["url"] : null;
    imageUUID =
        jsondata["images"].length > 0 ? jsondata["images"][0]["uuid"] : null;
    rawdata = jsondata;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map["uuid"] = uuid;
    map["name"] = name;
    map["description"] = description;
    map["duration"] = duration;
    map["body"] = body;
    map["price"] = price;
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    map["organiser"] = organiser;
    map["businessHour"] = businessHour;
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

  Widget getImage() {
    //try fetch from "url"
    if (this.imageURL != null && this.imageURL != "") {
      print(imageURL);
      return CachedNetworkImage(
        fit: BoxFit.fitWidth,
        imageUrl: imageURL!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => new CircularProgressIndicator(),
        errorWidget: (context, url, error) => new Icon(Icons.error),
      );
    } else if (this.imageUUID != null && this.imageUUID != "") {
      //try fetch from uuid
      var downloadURL = TIHDataProvider.getImageURLByImageUUID(this.imageUUID!);
      print(downloadURL);
      return CachedNetworkImage(
        imageUrl: downloadURL,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) =>
            Center(child: new CircularProgressIndicator()),
        errorWidget: (context, url, error) => new Icon(Icons.error),
      );
    } else {
      //no available image, return place holder
      print("WARNING: no image found for event");
      return Image.asset(
        "assets/img/placeholder.png",
        fit: BoxFit.fitWidth,
      );
    }
  }

  List<String> _getBusinessHour(jsonList) {
    List<String> result = <String>[];
    for (final day in jsonList) {
      String dayName = StringUtils.capitalize(day["day"].toString());
      String startTime = day["openTime"];
      String endTime = day["closeTime"];
      result.add("$dayName: $startTime ~ $endTime");
    }
    return result;
  }
}
