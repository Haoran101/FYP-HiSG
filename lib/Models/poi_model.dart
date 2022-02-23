import 'package:wikitude_flutter_app/Models/review_model.dart';

class POI {
  String? placeId;
  String? name;
  Map<String, double>? location;
  List<String>? types;
  String? iconURL;
  String? website;
  String? formattedAddress;
  String? phoneNumber;
  String? vicinity;
  double? rating;
  int? numberOfUsersRated;
  bool? openNow;
  String? businessStatus;
  List<String>? openingHour;
  List<Review>? reviews;
  List<String>? photoReferences;
  Map<String, dynamic>? details;

  toString() {
    return """POI(placeId: $placeId, name: $name, location: $location, types: $types,
    iconURL: $iconURL, website: $website, formattedAddress: $formattedAddress, phoneNumber: $phoneNumber, 
    vicinity: $vicinity, rating: $rating, businessStatus: $businessStatus,
    numberOfUsersRated: $numberOfUsersRated, openNow: $openNow, 
    openingHour: $openingHour
    photoReferences: $photoReferences, 
    reviews: $reviews)""";
  }

  POI.fromJSON(json) {
    details = json;
    placeId = json["place_id"];
    name = json["name"];
    location = Map<String, double>();
    location!["lat"] = json["geometry"]["location"]["lat"];
    location!["lng"] = json["geometry"]["location"]["lng"];
    types = List.generate(
        json["types"].length, (int index) => json["types"][index].toString());
    iconURL = json["icon"];
    website = json["website"];
    formattedAddress = json["formatted_address"];
    phoneNumber = json["international_phone_number"];
    vicinity = json["vicinity"];
    rating = json["rating"] == null? -1 : json["rating"]!.toDouble();
    numberOfUsersRated = json["user_ratings_total"];
    businessStatus = json["business_status"];
    if (json.containsKey("opening_hours")) {
      openNow = json["opening_hours"]["open_now"];
      openingHour = List.generate(
          json["opening_hours"]["weekday_text"].length,
          (int index) =>
              json["opening_hours"]["weekday_text"][index].toString());
    }
    // ignore: deprecated_member_use
    if (json.containsKey("reviews") && json["reviews"]!= null) {
      reviews = List.generate(
          json["reviews"].length,
          (int index) =>
              Review.fromJSON(this.placeId, index, json["reviews"][index]));
    }
    if (json.containsKey("photos") && json["photos"]!= null) {
    photoReferences = List.generate(json["photos"].length,
        (int index) => json["photos"][index]["photo_reference"]);
    }
  }
}

final businessStatusDefault = "OPERATIONAL";

final openingHoursDefault = {
  "open_now": true,
  "periods": [
    {
      "open": {"day": 0, "time": "0000"}
    }
  ],
  "weekday_text": [
    "Monday: Open 24 hours",
    "Tuesday: Open 24 hours",
    "Wednesday: Open 24 hours",
    "Thursday: Open 24 hours",
    "Friday: Open 24 hours",
    "Saturday: Open 24 hours",
    "Sunday: Open 24 hours"
  ]
};
