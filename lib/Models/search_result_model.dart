// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Models/poi_model.dart';
import 'package:wikitude_flutter_app/UI/activity_icon_provider.dart';

enum DataSource {
  Google,
  Google_Wikitude,
  TIH,
  TIH_Test_Backup,
  MRT,
  Video360,
  Article,
  Photo360,
  Video360YouTube,
  Hotels
}

extension ParseToString on DataSource {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class SearchResult {
  String resultId = " ";
  String title = " ";
  String? subtitle;
  Icon? icon;
  DataSource? source;
  Map<String, dynamic>? details;
  String? imageSnapshot;

  final _iconProvider = IconProvider();

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> mapData = new Map<String, dynamic>();
    mapData["resultId"] = resultId;
    mapData["title"] = title;
    mapData["subtitle"] = subtitle;
    mapData["icon"] = _iconProvider.IconToString(icon!);
    mapData["source"] = source!.toShortString();
    mapData["details"] = details;
    return mapData;
  }

  SearchResult.fromDataBaseJSON(Map<String, dynamic> jsondata) {
    title = jsondata["title"];
    subtitle = jsondata["subtitle"];
    icon = _iconProvider.stringToIcon(jsondata["icon"]);
    source = _stringToDataSource[jsondata["source"]];
    details = jsondata["details"];
    resultId = jsondata["resultId"];
  }

  SearchResult.fromGoogle(Map<String, dynamic> jsondata) {
    title = jsondata["name"].toString();
    var _typeImportant = _searchImportantGoogleType(jsondata["types"]);
    subtitle = _textConverter(_typeImportant);
    icon = _iconProvider.mapGoogleIcon(_typeImportant);
    source = DataSource.Google;
    details = jsondata;
    var placeId = jsondata["place_id"];
    resultId = "Google>$placeId";
  }

  SearchResult.fromTIH(Map<String, dynamic> jsondata) {
    print(jsondata);
    title = jsondata["name"].toString();
    icon = _iconProvider.mapTIHIcon(jsondata["dataset"]);
    subtitle = _textConverter(jsondata["dataset"]);
    source =  DataSource.TIH;
    details = jsondata;
    var dataset = jsondata["dataset"];
    var uuid = jsondata["uuid"];
    resultId = "TIH>$dataset>$uuid";
  }

  SearchResult.fromTIHBackUp(Map<String, dynamic> jsondata){
    title = jsondata["name"].toString();
    icon = _iconProvider.mapTIHIcon(jsondata["dataset"]);
    subtitle = _textConverter(jsondata["dataset"]);
    source =  DataSource.TIH_Test_Backup;
    details = jsondata;
    var dataset = jsondata["dataset"];
    var uuid = jsondata["test_uuid"];
    resultId = "TIH>$dataset>$uuid";
  }

  SearchResult.fromPOIModel(POI poi){
    title = poi.name!;
    var _typeImportant = _searchImportantGoogleType(poi.types!);
    subtitle = _textConverter(_typeImportant);
    icon = _iconProvider.mapGoogleIcon(_typeImportant);
    source = DataSource.Google;
    details = poi.details;
    var placeId = poi.placeId;
    resultId = "Google>$placeId";
  }

  SearchResult.from360ImageDataset(Map<String, dynamic> jsondata) {
    title = jsondata["title"].toString();
    icon = _iconProvider.IMAGE_360_ICON;
    source = DataSource.Photo360;
    details = jsondata;
    subtitle = "360 PHOTO";
    var docref = jsondata["data_handle"];
    imageSnapshot = jsondata["preview_img_url"];
    resultId = "cloud>360_photos>$docref";
  }

  SearchResult.from360VideoStorage(Map<String, dynamic> jsondata) {
    title = jsondata["name"].toString();

    icon = _iconProvider.VIDEO_360_ICON;
    source = DataSource.Video360;
    details = jsondata;
    subtitle = "360 VIDEO";
    var docref = jsondata["name"].toLowerCase().replaceAll("-", "").replaceAll(" ", "_");
    imageSnapshot = jsondata["preview_url"];
    resultId = "cloud>360_video_storage>$docref";
  }

  SearchResult.from360VideoYouTube(Map<String, dynamic> jsondata) {
    title = jsondata["snippet"]["title"].toString();

    icon = _iconProvider.VIDEO_360_ICON;
    source = DataSource.Video360YouTube;
    details = jsondata;
    subtitle = "360 VIDEO";
    var docref = jsondata["contentDetails"]["videoId"];
    imageSnapshot = jsondata["snippet"]["thumbnails"]["high"]["url"];
    resultId = "cloud>360_videos>$docref";
  }

  SearchResult.fromMRTdataset(Map<String, dynamic> jsondata) {
    title = jsondata["Name Engish Malay"].toString();

    icon = _iconProvider.MRT_ICON;
    source = DataSource.MRT;
    details = jsondata;
    subtitle = "MRT/LRT STATION";
    var docref = title.replaceAll(" ", "_").toLowerCase();
    resultId = "cloud>MRT>$docref";
  }

  SearchResult.fromMRTLines(Map<String, dynamic> jsondata) {
    title = jsondata["Station Name"].toString();
    icon = _iconProvider.MRT_ICON;
    source = DataSource.MRT;
    details = jsondata;
    subtitle = "MRT/LRT STATION";
    var docref = jsondata["docRef"];
    resultId = "cloud>MRT>$docref";
  }

  SearchResult.fromHotelsDataset(Map<String, dynamic> jsondata) {
    title = jsondata["name"].toString();

    icon = _iconProvider.HOTEL_ICON;
    source = DataSource.Hotels;
    details = jsondata;
    subtitle = "HOTEL";
    var docref = jsondata["place_id"];
    resultId = "cloud>hotels>$docref";
  }
}

String _textConverter(String text) {
  if (text == "lodging") {
    return "ACCOMMODATION";
  }
  return text.split("_").join(" ").toUpperCase();
}

String _searchImportantGoogleType(List<dynamic> types) {
  List<String> typePriority = ["lodging", "university", "school", 
  "subway_station", "bank", "health", "shopping_mall", "health"];
  for (final x in typePriority){
    if (types.contains(x)) {
    return x;
    }
  }
  return types.first;
}

Map<String, DataSource> _stringToDataSource = {
  "Google" : DataSource.Google,
  "TIH" : DataSource.TIH,
  "MRT" : DataSource.MRT,
  "Video360" : DataSource.Video360,
  "Article" : DataSource.Article,
  "Photo360" : DataSource.Photo360,
  "Video360YouTube" : DataSource.Video360YouTube,
  "Hotels" : DataSource.Hotels,
};
