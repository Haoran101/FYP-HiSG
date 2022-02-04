class TIHEventDetails {
  String? uuid;
  String? name;
  String? description;
  String? body;
  String? price;
  double? latitude;
  double? longtitude;
  String? organiser;
  String? imageURL;
  String? type;
  DateTime? startDate;
  DateTime? endDate;
  String? contactNumber;
  String? email;
  List<String>? language;
  String? nearstMRTStation;


  TIHEventDetails.fromEventJSON(Map<String, dynamic> jsondata) {
    uuid = jsondata["uuid"];
    name = jsondata["name"];
    description = jsondata["description"];
    body = jsondata["body"];
    price = jsondata["price"];
    latitude = jsondata["location"]["latitude"].toDouble();
    longtitude = jsondata["location"]["longtitude"].toDouble();
    organiser = jsondata["eventOrganizer"]?? jsondata["companyDisplayName"];
    imageURL = jsondata["images"][0]["url"];
    type = jsondata["type"];
    startDate = DateTime.parse(jsondata["startDate"]);
    endDate = DateTime.parse(jsondata["endDate"]);
    contactNumber = jsondata["contact"]["primaryContactNo"];
    email = jsondata["officialEmail"];
    language = List.castFrom(["supportedLanguage"]);
    nearstMRTStation = jsondata["nearestMrtStation"];
  }

  Map<String, dynamic> toJSON(){
    Map<String, dynamic> map = Map<String, dynamic>();
    map["uuid"] = uuid;
    map["name"] = name;
    map["description"] = description;
    map["body"] = body;
    map["price"] = price;
    map["latitude"] = latitude;
    map["longtitude"] = longtitude;
    map["organiser"] = organiser;
    map["imageURL"] = imageURL;
    map["type"] = type;
    map["startDate"] = startDate;
    map["contactNumber"] = contactNumber;
    map["email"] = email;
    map["language"] = language;
    map["nearstMRTStation"] = nearstMRTStation;

    return map;

  }

}