import 'dart:convert';

import 'package:wikitude_flutter_app/Models/search_result_model.dart';

class Plan {
  List<Day> days = <Day>[];

  getDayRefList() {
    return List.generate(days.length, (index) => days[index].dayRef);
  }

  toFullJSON() {
    return List.generate(days.length, (index) => days[index].toFullJSON());
  }

  toKeyedJSON() {
    return List.generate(days.length, (index) => days[index].toKeyedJSON());
  }

  Plan.fromJSON(jsonList) {
    days = List.generate(jsonList.length, (index) => Day.fromJSON(jsonList[index]));
  }
}

class Day {
  String dayRef = " ";
  List<SearchResult> activities = <SearchResult>[];

  toFullJSON() {
    return {
      "dayRef": dayRef,
      "activities": List.generate(
          activities.length, (index) => activities[index].toJSON()) 
          // all data from search result
    };
  }

  toKeyedJSON() {
    return {
      "dayRef": dayRef,
      "activities": List.generate(
          activities.length, (index) => activities[index].resultId)
          //only resultId from searchResult
    };
  }

  Day.fromJSON(jsonData) {
    dayRef = jsonData["dayRef"];
    activities = List.generate(jsonData["activities"].length, (index) => 
    SearchResult.fromDataBaseJSON(jsonData["activities"][index]));
  }
}
