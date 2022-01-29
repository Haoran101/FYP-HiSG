// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/UI/activity_icon_provider.dart';

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

extension ParseToString on DataSource {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class SearchResult {
  String title = " ";
  String? subtitle;
  Icon? icon;
  DataSource? source;
  Map<String, dynamic>? details;
  bool favoriated = false;
  bool planned = false;

  final _iconProvider = IconProvider();

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> mapData = new Map<String, dynamic>();
    mapData["title"] = title;
    mapData["subtitle"] = subtitle;
    mapData["icon"] = _iconProvider.IconToString(icon!);
    mapData["source"] = source!.toShortString();
    mapData["details"] = details;
    mapData["favoriated"] = favoriated;
    mapData["planned"] = planned;
    return mapData;
  }

  SearchResult.fromDataBaseJSON(Map<String, dynamic> jsondata) {
    title = jsondata["title"];
    subtitle = jsondata["subtitle"];
    icon = _iconProvider.stringToIcon(jsondata["icon"]);
    source = _stringToDataSource[jsondata["source"]];
    details = jsondata["details"];
    favoriated = jsondata["favoriated"];
    planned = jsondata["planned"];
  }

  SearchResult.fromGoogle(Map<String, dynamic> jsondata) {
    title = jsondata["name"].toString();

    subtitle = _textConverter(jsondata["types"].first);
    icon = _iconProvider.mapGoogleIcon(jsondata["types"].first);
    source = DataSource.Google;
    details = jsondata;
  }

  SearchResult.fromTIH(Map<String, dynamic> jsondata) {
    title = jsondata["name"].toString();
    icon = _iconProvider.mapTIHIcon(jsondata["dataset"]);
    subtitle = _textConverter(jsondata["dataset"]);
    source = DataSource.TIH;
    details = jsondata;
  }

  SearchResult.from360ImageDataset(Map<String, dynamic> jsondata) {
    title = jsondata["title"].toString();

    icon = _iconProvider.IMAGE_360_ICON;
    source = DataSource.Photo360;
    details = jsondata;
    subtitle = "360 PHOTO";
  }

  SearchResult.from360VideoStorage(Map<String, dynamic> jsondata) {
    title = jsondata["name"].toString();

    icon = _iconProvider.VIDEO_360_ICON;
    source = DataSource.Video360;
    details = jsondata;
    subtitle = "360 VIDEO";
  }

  SearchResult.from360VideoYouTube(Map<String, dynamic> jsondata) {
    title = jsondata["snippet"]["title"].toString();

    icon = _iconProvider.VIDEO_360_ICON;
    source = DataSource.Video360YouTube;
    details = jsondata;
    subtitle = "360 VIDEO";
  }

  SearchResult.fromMRTdataset(Map<String, dynamic> jsondata) {
    title = jsondata["Name Engish Malay"].toString();

    icon = _iconProvider.MRT_ICON;
    source = DataSource.MRT;
    details = jsondata;
    subtitle = "MRT STATION";
  }

  SearchResult.fromHotelsDataset(Map<String, dynamic> jsondata) {
    title = jsondata["name"].toString();

    icon = _iconProvider.HOTEL_ICON;
    source = DataSource.Hotels;
    details = jsondata;
    subtitle = "HOTEL";
  }
}

String _textConverter(String text) {
  return text.split("_").join(" ").toUpperCase();
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
