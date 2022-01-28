import 'package:flutter/material.dart';

enum DataSource {
  Google,
  TIH,
  MRT,
  Video360,
  Article,
  Photo360,
  Video360YouTube,
  Hotels
}

class SearchResult {
  String title = " ";
  String? subtitle;
  Icon? icon;
  DataSource? source;
  Map<String, dynamic>? details;

  SearchResult.fromGoogle(Map<String, dynamic> jsondata) {
    title = jsondata["name"].toString();

    subtitle = _textConverter(jsondata["types"].first);
    icon = _mapGoogleIcon(jsondata["types"].first);
    source = DataSource.Google;
    details = jsondata;
  }

  SearchResult.fromTIH(Map<String, dynamic> jsondata) {
    title = jsondata["name"].toString();

    icon = _mapTIHIcon(jsondata["dataset"]);
    subtitle = _textConverter(jsondata["dataset"]);
    source = DataSource.TIH;
    details = jsondata;
  }

  SearchResult.from360ImageDataset(Map<String, dynamic> jsondata) {
    title = jsondata["title"].toString();

    icon = Icon(Icons.vrpano_outlined, color: Colors.indigo);
    source = DataSource.Photo360;
    details = jsondata;
    subtitle = "360 PHOTO";
  }

  SearchResult.from360VideoStorage(Map<String, dynamic> jsondata) {
    title = jsondata["name"].toString();

    icon = Icon(Icons.video_collection_outlined, color: Colors.indigo);
    source = DataSource.Video360;
    details = jsondata;
    subtitle = "360 VIDEO";
  }

  SearchResult.from360VideoYouTube(Map<String, dynamic> jsondata) {
    title = jsondata["snippet"]["title"].toString();

    icon = Icon(Icons.video_collection_outlined, color: Colors.indigo);
    source = DataSource.Video360YouTube;
    details = jsondata;
    subtitle = "360 VIDEO";
  }

  SearchResult.fromMRTdataset(Map<String, dynamic> jsondata) {
    title = jsondata["Name Engish Malay"].toString();

    icon = Icon(Icons.directions_transit, color: Colors.blueGrey[300]);
    source = DataSource.MRT;
    details = jsondata;
    subtitle = "MRT STATION";
  }

  SearchResult.fromHotelsDataset(Map<String, dynamic> jsondata) {
    title = jsondata["name"].toString();

    icon = Icon(Icons.local_hotel, color: Colors.cyan);
    source = DataSource.Hotels;
    details = jsondata;
    subtitle = "HOTEL";
  }
}

final _BUS_iCON =
    Icon(Icons.directions_bus_filled_outlined, color: Colors.blueGrey[300]);
final _STORE_iCON = Icon(Icons.storefront_outlined, color: Colors.deepOrange);

final _HEALTH_ICON = Icon(
  Icons.local_hospital_outlined,
  color: Colors.teal,
);

final _FOOD_ICON = Icon(Icons.restaurant_menu_outlined, color: Colors.amber);

final _ATTRACTION_ICON =
    Icon(Icons.attractions_outlined, color: Colors.pink[700]);

final _SCHOOL_ICON = Icon(Icons.school_outlined, color: Colors.teal);

final _MONEY_ICON = Icon(Icons.attach_money_outlined, color: Colors.orange);

final _WINE_ICON = Icon(Icons.nightlife_outlined, color: Colors.purple[300]);

final _TREE_ICON = Icon(Icons.park_outlined, color: Colors.green);

_mapGoogleIcon(firstType) {
  switch (firstType) {
    case "bus_station":
      return _BUS_iCON;
    case "convenience_store":
      return _STORE_iCON;
    case "clothing_store":
      return _STORE_iCON;
    case "department_store":
      return _STORE_iCON;
    case "supermarket":
      return _STORE_iCON;
    case "shopping_mall":
      return _STORE_iCON;
    case "pet_store":
      return _STORE_iCON;
    case "pharmacy":
      return _HEALTH_ICON;
    case "drugstore":
      return _HEALTH_ICON;
    case "hospital":
      return _HEALTH_ICON;
    case "dentist":
      return _HEALTH_ICON;
    case "bakery":
      return _FOOD_ICON;
    case "cafe":
      return _FOOD_ICON;
    case "restaurant":
      return _FOOD_ICON;
    case "food":
      return _FOOD_ICON;
    case "meal_delivery":
      return _FOOD_ICON;
    case "meal_takeaway":
      return _FOOD_ICON;
    case "tourist_attraction":
      return _ATTRACTION_ICON;
    case "zoo":
      return _ATTRACTION_ICON;
    case "amusement_park":
      return _ATTRACTION_ICON;
    case "art_gallery":
      return _ATTRACTION_ICON;
    case "museum":
      return _ATTRACTION_ICON;
    case "university":
      return _SCHOOL_ICON;
    case "primary_school":
      return _SCHOOL_ICON;
    case "school":
      return _SCHOOL_ICON;
    case "secondary_school":
      return _SCHOOL_ICON;
    case "library":
      return _SCHOOL_ICON;
    case "atm":
      return _MONEY_ICON;
    case "bank":
      return _MONEY_ICON;
    case "bar":
      return _WINE_ICON;
    case "night_club":
      return _WINE_ICON;
    case "park":
      return _TREE_ICON;
    case "natural_feature":
      return _TREE_ICON;
    case "health":
      return _HEALTH_ICON;
    case "finance":
      return _MONEY_ICON;
    case "landmark":
      return _ATTRACTION_ICON;

    default:
      return Icon(Icons.place, color: Colors.red);
  }
}

_mapTIHIcon(dataset) {
  switch (dataset) {
    case "event":
      return Icon(
        Icons.local_activity_outlined,
        color: Colors.amber,
      );
    case "precincts":
      return Icon(Icons.villa_outlined, color: Colors.pink[700]);

    case "tour":
      return Icon(Icons.tour_outlined, color: Colors.red);

    case "walking_trail":
      return Icon(Icons.hiking_outlined, color: Colors.teal);
    default:
      return Icon(Icons.event_available_outlined);
  }
}

String _textConverter(String text) {
  return text.split("_").join(" ").toUpperCase();
}
