import 'dart:convert';

import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/User/UserService.dart';
import 'package:wikitude_flutter_app/User/user_database.dart';
final _userService = UserService();

class Plan {
  Map<String, dynamic> main = Map<String, dynamic>();
  List<Day> dayList = <Day>[];
  late Day archieve;
  Plan({required this.main});

  String toString() {
    return this.toMainJSON().toString();
  }

  Future init() async{
    //init list day
    List<Day> listday = [];
    for (Map<String, dynamic> dayItem in this.main["day_list"]){
      Day day = Day(name: dayItem["name"].toString());
      await day.initActivities(dayItem["activities"]);
      listday.add(day);
    }
    
    Day archieve = Day(name: "Archieve");
    await archieve.initActivities(this.main["archieve"]);
    listday.add(archieve);

    this.dayList = listday;
    this.archieve = archieve;
  }

  void updateMain() {
    this.main["next_day"] = this.dayList.length + 1;
    this.main["day_list"] = List.generate(
      this.dayList.length - 1, (index) => this.dayList[index].toMainJSON());
    this.main["archieve"] = this.archieve.toMainJSON()["activities"];
  }

  Map<String, dynamic> toMainJSON() {
    //updateMain();
    print("DayList:  " + this.dayList.toString());
    return this.main;
  }

  void addToArchieve(SearchResult item) {
    this.archieve.activities.add(item);
  }

}

class Day {
  String name = " ";
  late List<SearchResult> activities;
  Day({required this.name});

  String toString() {
    return this.toMainJSON().toString();
  }

  List<String> getActivityIdList() {
    return List.generate(this.activities.length, (index) => 
      this.activities[index].resultId);
  }

  Map<String, dynamic> toMainJSON() {
    Map<String, dynamic> mapData = Map<String, dynamic>();
    mapData["name"] = this.name;
    var resultIdList = List.generate(this.activities.length, (index) => 
      this.activities[index].resultId);
    //print(resultIdList);
    mapData["activities"] = resultIdList;
    return mapData;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> mapData = Map<String, dynamic>();
    mapData["name"] = this.name;
    mapData["activities"] = List.generate(this.activities.length, (index) => 
      this.activities[index].toJSON());
    return mapData;
  }

  Future initActivities(List<dynamic> resultIdList) async{
    List<String> activities = List.castFrom(resultIdList);
    _userService.fetchSearchResultsFromId(activities).then(
      (searchResultList) => this.activities = searchResultList
    );
  }
}
