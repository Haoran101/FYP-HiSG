import 'package:flutter/material.dart';

enum DataSource { Google, TIH, MRT, Video360, Article, Photo360, Video360YouTube, Hotels}

class SearchResult{

  String? title;
  String? subtitle;
  Icon? icon;
  DataSource? source;
  Map<String, dynamic>? details;

  SearchResult.fromGoogle(Map<String, dynamic> jsondata) {
    title = jsondata["name"];
    subtitle = textConverter(jsondata["types"].first);
    icon = Icon(Icons.place, color: Colors.red);
    source = DataSource.Google;
    details = jsondata;
  }

  SearchResult.fromTIH(Map<String, dynamic> jsondata) {
    title = jsondata["name"];
    icon = Icon(Icons.event_available_outlined);
    subtitle = textConverter(jsondata["dataset"]);
    source = DataSource.TIH;
    details = jsondata;
  }

  SearchResult.from360ImageDataset(Map<String, dynamic> jsondata) {
    title = jsondata["title"];
    icon = Icon(Icons.event_available_outlined);
    source = DataSource.Photo360;
    details = jsondata;
    subtitle = "360 PHOTO";
  }

  SearchResult.from360VideoStorage(Map<String, dynamic> jsondata) {
    title = jsondata["title"];
    icon = Icon(Icons.video_collection_outlined);
    source = DataSource.Video360;
    details = jsondata;
    subtitle = "360 VIDEO";
  }

  SearchResult.from360VideoYouTube(Map<String, dynamic> jsondata) {
    title = jsondata["snippet"]["title"];
    icon = Icon(Icons.video_collection_outlined);
    source = DataSource.Video360YouTube;
    details = jsondata;
    subtitle = "360 VIDEO";
  }

  SearchResult.fromMRTdataset(Map<String, dynamic> jsondata){
    title = jsondata["Name Engish Malay"];
    icon = Icon(Icons.directions_transit);
    source = DataSource.MRT;
    details = jsondata;
    subtitle = "MRT STATION";
  }

  SearchResult.fromHotelsDataset(Map<String, dynamic> jsondata){
    title = jsondata["name"];
    icon = Icon(Icons.local_hotel);
    source = DataSource.Hotels;
    details = jsondata;
    subtitle = "HOTEL";
  }

}

String textConverter(String text) {
  return text.split("_").join(" ").toUpperCase();
}