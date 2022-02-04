// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class IconProvider {
  final NOT_FAVORITED_ICON = Icon(
    Icons.favorite_border,
    color: Colors.white,
    size: 30,
  );

  final FAVORITED_ICON =
      Icon(Icons.favorite_outlined, color: Colors.amber, size: 30);

  final VIDEO_360_ICON =
      Icon(Icons.video_collection_outlined, color: Colors.indigo);

  final MRT_ICON = Icon(Icons.directions_transit, color: Colors.blueGrey[300]);

  final HOTEL_ICON = Icon(Icons.local_hotel, color: Colors.cyan);

  final BUS_iCON =
      Icon(Icons.directions_bus_filled_outlined, color: Colors.blueGrey[300]);
  final STORE_iCON = Icon(Icons.storefront_outlined, color: Colors.deepOrange);

  final HEALTH_ICON = Icon(
    Icons.local_hospital_outlined,
    color: Colors.teal,
  );

  final IMAGE_360_ICON = Icon(Icons.vrpano_outlined, color: Colors.indigo);

  final FOOD_ICON = Icon(Icons.restaurant_menu_outlined, color: Colors.amber);

  final ATTRACTION_ICON =
      Icon(Icons.attractions_outlined, color: Colors.pink[700]);

  final SCHOOL_ICON = Icon(Icons.school_outlined, color: Colors.teal);

  final MONEY_ICON = Icon(Icons.attach_money_outlined, color: Colors.orange);

  final WINE_ICON = Icon(Icons.nightlife_outlined, color: Colors.purple[300]);

  final TREE_ICON = Icon(Icons.park_outlined, color: Colors.green);

  final EVENT_ICON = Icon(
    Icons.local_activity_outlined,
    color: Colors.amber,
  );

  final PRECINCT_ICON = Icon(Icons.villa_outlined, color: Colors.pink[700]);

  final TOUR_ICON = Icon(Icons.tour_outlined, color: Colors.red);

  final WALKING_TRAIL_ICON = Icon(Icons.hiking_outlined, color: Colors.teal);

  final TIH_DEFAULT_ICON = Icon(Icons.event_available_outlined);

  final GOOGLE_DEFAULT_ICON = Icon(Icons.place, color: Colors.red);

  Icon stringToIcon(String iconString) {
    Map<String, Icon> map = {
      "GOOGLE_DEFAULT_ICON": GOOGLE_DEFAULT_ICON,
      "TIH_DEFAULT_ICON": TIH_DEFAULT_ICON,
      "WALKING_TRAIL_ICON": WALKING_TRAIL_ICON,
      "TOUR_ICON": TOUR_ICON,
      "VIDEO_360_ICON": VIDEO_360_ICON,
      "MRT_ICON": MRT_ICON,
      "HOTEL_ICON": HOTEL_ICON,
      "BUS_iCON": BUS_iCON,
      "HEALTH_ICON": HEALTH_ICON,
      "IMAGE_360_ICON": IMAGE_360_ICON,
      "FOOD_ICON": FOOD_ICON,
      "ATTRACTION_ICON": ATTRACTION_ICON,
      "SCHOOL_ICON": SCHOOL_ICON,
      "MONEY_ICON": MONEY_ICON,
      "WINE_ICON": WINE_ICON,
      "TREE_ICON": TREE_ICON,
      "EVENT_ICON": EVENT_ICON,
      "PRECINCT_ICON": PRECINCT_ICON,
    };
    return map[iconString]!;
  }

  String IconToString(Icon icon) {
    Map<Icon, String> map = {
      GOOGLE_DEFAULT_ICON: "GOOGLE_DEFAULT_ICON",
      TIH_DEFAULT_ICON: "TIH_DEFAULT_ICON",
      WALKING_TRAIL_ICON: "WALKING_TRAIL_ICON",
      TOUR_ICON: "TOUR_ICON",
      VIDEO_360_ICON: "VIDEO_360_ICON",
      MRT_ICON: "MRT_ICON",
      HOTEL_ICON: "HOTEL_ICON",
      BUS_iCON: "BUS_iCON",
      HEALTH_ICON: "HEALTH_ICON",
      IMAGE_360_ICON: "IMAGE_360_ICON",
      FOOD_ICON: "FOOD_ICON",
      ATTRACTION_ICON: "ATTRACTION_ICON",
      SCHOOL_ICON: "SCHOOL_ICON",
      MONEY_ICON: "MONEY_ICON",
      WINE_ICON: "WINE_ICON",
      TREE_ICON: "TREE_ICON",
      EVENT_ICON: "EVENT_ICON",
      PRECINCT_ICON: "PRECINCT_ICON",
    };
    return map[icon]!;
  }

  mapGoogleIcon(firstType) {
    switch (firstType) {
      case "lodging":
        return HOTEL_ICON;
      case "bus_station":
        return BUS_iCON;
      case "convenience_store":
        return STORE_iCON;
      case "clothing_store":
        return STORE_iCON;
      case "department_store":
        return STORE_iCON;
      case "supermarket":
        return STORE_iCON;
      case "shopping_mall":
        return STORE_iCON;
      case "pet_store":
        return STORE_iCON;
      case "pharmacy":
        return HEALTH_ICON;
      case "drugstore":
        return HEALTH_ICON;
      case "hospital":
        return HEALTH_ICON;
      case "dentist":
        return HEALTH_ICON;
      case "bakery":
        return FOOD_ICON;
      case "cafe":
        return FOOD_ICON;
      case "restaurant":
        return FOOD_ICON;
      case "food":
        return FOOD_ICON;
      case "meal_delivery":
        return FOOD_ICON;
      case "meal_takeaway":
        return FOOD_ICON;
      case "tourist_attraction":
        return ATTRACTION_ICON;
      case "zoo":
        return ATTRACTION_ICON;
      case "amusement_park":
        return ATTRACTION_ICON;
      case "art_gallery":
        return ATTRACTION_ICON;
      case "museum":
        return ATTRACTION_ICON;
      case "university":
        return SCHOOL_ICON;
      case "primary_school":
        return SCHOOL_ICON;
      case "school":
        return SCHOOL_ICON;
      case "secondary_school":
        return SCHOOL_ICON;
      case "library":
        return SCHOOL_ICON;
      case "atm":
        return MONEY_ICON;
      case "bank":
        return MONEY_ICON;
      case "bar":
        return WINE_ICON;
      case "night_club":
        return WINE_ICON;
      case "park":
        return TREE_ICON;
      case "natural_feature":
        return TREE_ICON;
      case "health":
        return HEALTH_ICON;
      case "finance":
        return MONEY_ICON;
      case "landmark":
        return ATTRACTION_ICON;

      default:
        return GOOGLE_DEFAULT_ICON;
    }
  }

  mapTIHIcon(dataset) {
    switch (dataset) {
      case "event":
        return EVENT_ICON;
      case "precincts":
        return PRECINCT_ICON;

      case "tour":
        return TOUR_ICON;

      case "walking_trail":
        return WALKING_TRAIL_ICON;
      default:
        return TIH_DEFAULT_ICON;
    }
  }

  mapTIHEventIcon(eventType) {
    switch (eventType) {
      case "Arts":
        return Icon(
          Icons.palette_outlined,
        );
      case "Attractions":
        return ATTRACTION_ICON;
      case "Entertainment":
        return Icon(
          Icons.sentiment_very_satisfied_outlined,
        );

      case "Food & Beverages":
        return FOOD_ICON;
      case "History & Culture":
        return Icon(
          Icons.history_edu_outlined,
        );
      case "MICE":
        return Icon(
          Icons.groups_outlined,
        );
      case "Nature & Wildlife":
        return TREE_ICON;
      case "Shopping":
        return STORE_iCON;
      case "Sports":
        return Icon(
          Icons.directions_run_outlined,
        );
      default:
        return EVENT_ICON;
    }
  }

  
}
